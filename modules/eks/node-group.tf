# Managed node group that runs workloads in the private subnets.
resource "aws_eks_node_group" "my-eks-node-group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_role_arn   = aws_iam_role.node.arn
  node_group_name = "${var.cluster_name}-primary-ng"
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types
  ami_type        = var.ami_type
  disk_size       = 20

  # Keeps the sample cluster small and cost-conscious.
  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  # Replaces one node at a time during managed node group updates.
  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "my-eks-node-group"
  }
}
