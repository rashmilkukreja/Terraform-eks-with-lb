# Uses the selected AWS region for all infrastructure resources.
provider "aws" {
  region = var.region
  # profile = "personal" 
}

# Connects Terraform's Kubernetes provider to the newly created EKS API server.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
  token                  = module.eks.cluster_token
}

# Allows Terraform to install Helm charts into the EKS cluster.
provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
    token                  = module.eks.cluster_token
  }
}
