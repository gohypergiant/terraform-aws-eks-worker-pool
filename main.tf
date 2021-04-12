// Copyright 2020 Hypergiant, LLC

module "nodepools" {
  for_each = var.subnet_ids
  source   = "./modules/node-pool"

  name                        = var.name
  gpu_enabled                 = var.gpu_enabled
  cluster_name                = var.cluster_name
  min_size                    = var.min_size
  max_size                    = var.max_size
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.key_name
  instance_type               = var.instance_type
  security_groups             = var.security_groups
  subnet_id                   = each.key
  volume_size                 = var.volume_size
  volume_type                 = var.volume_type
}
