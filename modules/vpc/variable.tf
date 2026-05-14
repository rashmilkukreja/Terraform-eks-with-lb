# AWS region used by this VPC module.
variable "region" {
  description = "ap-south-1"
}

# CIDR block assigned to the VPC.
variable "cidr_block" {
  description = "Must use 16 block"
}

# CIDR blocks for private subnets.
variable "private_subnet" {
  description = "Privet subnet"
}

# CIDR blocks for public subnets.
variable "public_subnet" {
  description = "Public subnet"
}

# Availability Zones used to place subnets.
variable "azs" {
  description = "Availability Zones"
}

# EKS cluster name used in Kubernetes subnet discovery tags.
variable "cluster_name" {
  description = "Cluster name"
}
