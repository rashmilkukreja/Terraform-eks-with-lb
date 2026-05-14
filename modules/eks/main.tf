# EKS control plane for the Kubernetes cluster.
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn

  # Enables control plane logs for API server and audit events.
  enabled_cluster_log_types = [
    "api", "audit",
  ]

  # Disables EKS Auto Mode compute so this module manages nodes explicitly.
  compute_config {
    enabled = false
  }

  # Places the control plane endpoints in the supplied VPC subnets.
  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]

}
