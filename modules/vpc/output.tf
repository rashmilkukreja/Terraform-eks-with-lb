# Public subnet IDs for internet-facing AWS load balancers.
output "public_subnets" {
  value = aws_subnet.public_subnet[*].id
}

# Private subnet IDs where EKS worker nodes are launched.
output "private_subnets" {
  value = aws_subnet.private_subnet[*].id
}

# Security group ID exported for consumers that need the shared VPC group.
output "sg_group" {
  value = aws_security_group.sg_group.id
}

# VPC ID consumed by the EKS module and other dependent resources.
output "my_vpc" {
  value = aws_vpc.my_vpc.id
}
