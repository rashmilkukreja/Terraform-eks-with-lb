module "vpc" {
  source         = "./modules/vpc"
  region         = var.region
  cidr_block     = var.cidr_block
  private_subnet = var.private_subnet
  public_subnet  = var.public_subnet
  azs            = var.azs
  cluster_name = var.cluster_name
}

module "eks" {
  depends_on    = [ module.vpc ]
  source        = "./modules/eks"
  cluster_name  = var.cluster_name
  vpc_id        = module.vpc.my_vpc
  subnet_ids    = module.vpc.private_subnets
  ami_type     = var.ami_type
  ec2_ssh_key  = var.ec2_ssh_key
  instance_types = var.instance_types
  region = var.region

}

resource "null_resource" "kubeconfig" {
  depends_on = [
    module.eks
  ]

  provisioner "local-exec" {
  command = "AWS_PROFILE=${var.aws_profile} aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

  triggers = {
    cluster_name = module.eks.cluster_name
  }
}
