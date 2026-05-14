# Name used for the EKS cluster and related AWS resources.
variable "cluster_name" {
  type    = string
  default = "cluster_name"
}

# VPC ID where the cluster and load balancer controller operate.
variable "vpc_id" {
  type = string
}

# Private subnet IDs used by the managed node group and cluster networking.
variable "subnet_ids" {
  type = list(string)
}

# EC2 instance types used by the managed node group.
variable "instance_types" {
  default = "EKS NODE TYPES"
}

# AMI family used for EKS managed node instances.
variable "ami_type" {
  description = "AMI type"
}

# Existing EC2 key pair name for node SSH access, if wired into launch settings.
variable "ec2_ssh_key" {
  description = "SSH keys for Remote"
}

# AWS region passed to add-ons such as the AWS Load Balancer Controller.
variable "region" {
  description = "Mumbai Region"
}
