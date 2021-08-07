data "aws_ssm_parameter" "eks_ami" {
  name = var.gpu_enabled ? (
    "/aws/service/eks/optimized-ami/${data.aws_eks_cluster.this.version}/amazon-linux-2-gpu/recommended/image_id") : (
    "/aws/service/eks/optimized-ami/${data.aws_eks_cluster.this.version}/amazon-linux-2/recommended/image_id"
  )
}

data "aws_subnet" "this" {
  id = var.subnet_id
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

locals {
  base_labels = [
    "eks.amazonaws.com/nodegroup-image=${data.aws_ssm_parameter.eks_ami.value}",
    "${var.name}-az=${data.aws_subnet.this.availability_zone},"
  ]
  all_labels = join(",", concat(local.base_labels, var.k8s_labels))
  user_data  = <<EOF
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh ${data.aws_eks_cluster.this.id} \
    --kubelet-extra-args \
    '--node-labels=${local.all_labels}'
    EOF

  cluster_id = {
    key                 = "kubernetes.io/cluster/${data.aws_eks_cluster.this.id}"
    value               = "owned"
    propagate_at_launch = true
  }

  cluster_name = {
    key                 = "eks:cluster-name"
    value               = data.aws_eks_cluster.this.id
    propagate_at_launch = true
  }

  cluster_autoscaler_tags = var.cluster_autoscaler ? [
    {
      key                 = "k8s.io/cluster-autoscaler/${data.aws_eks_cluster.this.id}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = "true"
      propagate_at_launch = true
    },
  ] : []

  cluster_autoscaler_gpu_tags = var.gpu_enabled ? {
    key                 = "k8s.io/cluster-autoscaler/node-template/gpu-enabled"
    value               = "true"
    propagate_at_launch = true
  } : {}
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-instance-profile"
  role = var.role_name
}

module "nodepool-asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "4.4.0"

  # Auto scaling group
  vpc_zone_identifier         = toset([data.aws_subnet.this.id])
  health_check_type           = "EC2"
  min_size                    = var.min_size
  max_size                    = var.max_size
  desired_capacity            = var.desired_capacity
  wait_for_capacity_timeout   = 0
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.key_name
  iam_instance_profile_name   = aws_iam_instance_profile.this.id

  name = "${var.name}-${data.aws_subnet.this.availability_zone}"

  # Launch configuration
  lc_name   = "${var.name}-${data.aws_subnet.this.availability_zone}"
  use_lc    = true
  create_lc = true

  # Use the SSM because apparently that's how AWS wants you to do it
  image_id = data.aws_ssm_parameter.eks_ami.value

  instance_type = var.instance_type

  security_groups = var.security_groups

  user_data_base64 = base64encode(local.user_data)

  root_block_device = [
    {
      volume_size = var.volume_size
      volume_type = var.volume_type
    },
  ]

  tags = flatten([local.cluster_id, local.cluster_name, local.cluster_autoscaler_tags, local.cluster_autoscaler_gpu_tags, var.tags])
}
