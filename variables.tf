// Copyright 2020 Hypergiant, LLC

variable "name" {
  type        = string
  description = "Name of autoscaling group"
}

variable "gpu_enabled" {
  type        = bool
  description = "Whether to use GPU AMI and tags"
  default     = false
}

variable "cluster_name" {
  type        = string
  description = "Name of Kubernetes cluster"
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

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate public IP address with ASG instances. Useful for debugging."
  default     = false
}

variable "key_name" {
  type        = string
  description = "SSH key name. Optional."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs to deploy worker pool into. Availability zones are inferred from subnets. One autoscaling worker pool per subnet."
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
