# General-purpose VPC security group that currently permits SSH ingress.
resource "aws_security_group" "sg_group" {
  name        = "sg_group"
  description = "Security group"
  vpc_id      = aws_vpc.my_vpc.id

  # Allows SSH access from any IPv4 address.
  ingress {
    description = "security group"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allows all outbound traffic from resources attached to this group.
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}
