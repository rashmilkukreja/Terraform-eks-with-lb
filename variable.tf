# AWS region where the VPC, EKS cluster, and supporting resources are created.
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

# Local AWS CLI profile used by the kubeconfig update command.
variable "aws_profile" {
  default = "personal"
}

# Deployment environment label for future tagging or naming use.
variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
  default     = "dev"
}

# CIDR range assigned to the project VPC.
variable "cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

# Private subnet CIDR ranges used by the EKS worker nodes.
variable "private_subnet" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

# Public subnet CIDR ranges used by internet-facing load balancers and NAT.
variable "public_subnet" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default = [
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24"
  ]
}

# Availability Zones mapped by index to the public and private subnet lists.
variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default = [
    "ap-south-1a",
    "ap-south-1b",
    "ap-south-1c"
  ]
}

# Name assigned to the EKS cluster and related resources.
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks"
}

# Kubernetes control plane version requested for EKS.
variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.34"
}

# EC2 instance types used by the managed EKS node group.
variable "instance_types" {
  description = "EC2 instance types for node group"
  type        = list(string)
  default     = ["t3.medium"]
}

# AMI family used for managed EKS worker nodes.
variable "ami_type" {
  description = "AMI type for EKS nodes"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

# Existing EC2 key pair name for SSH access to worker nodes, if enabled.
variable "ec2_ssh_key" {
  description = "SSH key pair name for worker nodes"
  type        = string
  default     = "sit-server"
}
