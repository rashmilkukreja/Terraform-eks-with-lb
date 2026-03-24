variable "cluster_name" {
  type = string
  default = "cluster_name"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_types" {
  default = "EKS NODE TYPES"
}

variable "ami_type" {
    description = "AMI type"
}

variable "ec2_ssh_key" {
  description = "SSH keys for Remote"
}

variable "region" {
  description = "Mumbai Region"
}