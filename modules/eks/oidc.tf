# Reads cluster identity information after the EKS control plane exists.
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.eks.name
}

# Creates an OIDC provider so Kubernetes service accounts can assume IAM roles.
resource "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  # STS is required for IAM Roles for Service Accounts (IRSA).
  client_id_list = [
    "sts.amazonaws.com"
  ]

  # Root CA thumbprint used by AWS to trust the EKS OIDC issuer.
  thumbprint_list = [
    "9e99a48a9960b14926bb7f3b02e22da0ecd3f3e4"
  ]
}
