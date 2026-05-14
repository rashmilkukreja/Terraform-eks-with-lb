# Main VPC with DNS support enabled for EKS service discovery.
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }

}

# Public subnets host internet-facing load balancers and the NAT gateway.
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet)
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet ${count.index + 1}"

    # These tags allow Kubernetes and the AWS Load Balancer Controller to discover public subnets.
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

# Private subnets host EKS worker nodes and internal load balancers.
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    "Name" = "Private-Subnet ${count.index + 1}"

    # These tags allow Kubernetes and the AWS Load Balancer Controller to discover private subnets.
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

# Internet gateway gives public subnets a path to the internet.
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

# Route table used by all public subnets.
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-public-rt"
  }
}

# Default public route sends internet traffic through the internet gateway.
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Associates each public subnet with the public route table.
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Route table used by private subnets.
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-private-rt"
  }
}

# Associates each private subnet with the private route table.
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# NAT gateway allows private subnets to reach the internet for updates and image pulls.
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.my_igw]

  tags = {
    Name = "my-nw"
  }
}

# Elastic IP attached to the NAT gateway.
resource "aws_eip" "my_eip" {
  domain = "vpc"
}

# Default private route sends outbound internet traffic through the NAT gateway.
resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway.id

  depends_on = [aws_eip.my_eip]
}
