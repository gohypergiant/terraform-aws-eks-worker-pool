variable "name" {
  type        = string
  description = "Name of autoscaling group"
}

variable "gpu_enabled" {
  type        = bool
  description = "Whether to use GPU AMI and tags"
}

variable "cluster_name" {
  type        = string
  description = "Name of Kubernetes cluster"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to use for autoscaling group"
}

variable "min_size" {
  type        = number
  description = "Minimum size of ASG. Can be set as low as 0."
  default     = 0
}

variable "max_size" {
  type        = number
  description = "Maximum size of ASG."
  default     = 1
}

variable "desired_capacity" {
  type        = number
  description = "Desired size of ASG. If cluster_autoscaler is enabled, may cause fluctiations in node pool size."
  default     = null
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate public IP address with ASG instances. Useful for debugging."
  default     = false
}

variable "key_name" {
  type        = string
  description = "SSH key name. Optional."
  default     = null
}

variable "instance_type" {
  type        = string
  description = "AWS EC2 instance type."
}

variable "security_groups" {
  type        = list(string)
  description = "List of security groups to attach to ASG instances."
}

variable "volume_size" {
  type        = number
  description = "Root volume size (in GB)"
  default     = 120
}

variable "volume_type" {
  type        = string
  description = "AWS EBS volume type"
  default     = "gp2"
}

variable "cluster_autoscaler" {
  type        = bool
  description = "whether to provide auto-scaling services"
  default     = false
}

variable "role_name" {
  type        = string
  description = "The role that should be applied"
}

variable "tags" {
  type        = list(map(string))
  description = "Tags to apply to the node pool"
  default     = []
}

variable "k8s_labels" {
  type        = list(string)
  description = "Extra labels to apply to Kubernetes workers"
  default     = []
}

variable "k8s_taints" {
  type        = list(string)
  description = "Node taints to apply to EKS workers"
  default     = []
}
