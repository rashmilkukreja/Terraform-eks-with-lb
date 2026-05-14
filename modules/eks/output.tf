# EKS cluster name exported for kubeconfig and dependent resources.
output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

# Kubernetes API server endpoint used by Kubernetes and Helm providers.
output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

# Base64-encoded cluster CA data used to authenticate provider connections.
output "cluster_certificate_authority" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}

# Fetches an authentication token for Terraform Kubernetes and Helm operations.
data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.eks.name
}

# Short-lived authentication token for the EKS API server.
output "cluster_token" {
  value = data.aws_eks_cluster_auth.this.token
}

# IAM OIDC provider ARN used by Kubernetes service accounts with IRSA.
output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc.arn
}

# IAM OIDC provider URL associated with this EKS cluster.
output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.oidc.url
}
