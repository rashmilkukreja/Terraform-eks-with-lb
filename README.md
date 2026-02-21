# terraform-eks-with-lb

Minimal Terraform repo to create a VPC, EKS cluster, node group, and deploy an nginx app exposed via an ALB (Ingress).
- For more details refer (Medium)[https://medium.com/@rashmil.kukreja/automating-deployment-of-cv-in-eks-cluster-with-lb-using-terraform-295b17f8ced4]

## Repo layout
- main.tf, providers.tf, backend.tf, variables.tf, outputs.tf, versions.tf — root orchestration
- modules/
  - vpc/ — VPC, subnets, NAT, route tables
  - eks/ — EKS control plane, node group, IAM, OIDC, ALB Helm/chart support
  - apps/nginx/ — Kubernetes Deployment, Service, Ingress (creates ALB)

## Prerequisites
- Terraform >= pinned in versions.tf
- AWS CLI configured with a profile (default `personal`)
- kubectl and helm available locally
- AWS credentials with permissions to create VPC/EKS/IAM/ELB resources

## Key notes / gotchas
- Root provider blocks configure `aws`, `kubernetes`, and `helm` using outputs from `module.eks` (cluster endpoint/cert/token). module.eks must finish before providers dependent on the cluster are used.
- The repo runs a `null_resource.kubeconfig` to call `aws eks update-kubeconfig` using `var.aws_profile`. Either set `-var='aws_profile=<profile>'` or export `AWS_PROFILE`.
- ALB created by the nginx app is expected to be named `${var.cluster_name}-nginx-alb`. The root uses a `time_sleep` then a `data "aws_lb"` by name to look it up — do not remove the sleep without validating ALB naming.
- Node group defaults to a single node (desired/min/max = 1) in modules/eks/node-group.tf.

## Quickstart
1. Initialize:
   terraform init

2. Plan:
   terraform plan -var='aws_profile=<profile>' -out=tfplan

3. Apply:
   terraform apply tfplan
   or
   terraform apply -auto-approve -var='aws_profile=<profile>'

After apply the `null_resource` attempts to update `~/.kube/config`. Verify:
- kubectl get pods -A --kubeconfig ~/.kube/config
- aws elbv2 describe-load-balancers --names ${var.cluster_name}-nginx-alb --profile <profile>

## Useful variables
- aws_profile — AWS CLI profile used by update-kubeconfig (default `personal`)
- cluster_name — EKS cluster name
- subnet_ids / vpc config — set via modules/vpc outputs consumed by module.eks

## Extending
- To add more apps, follow modules/apps/nginx structure (deployment.tf, service.tf, ingress.tf, variables.tf, outputs.tf).
- To reference the cluster in new modules, consume module.eks outputs: cluster_endpoint, cluster_certificate_authority, cluster_token.

## Troubleshooting
- Kubeconfig not updated: confirm AWS CLI profile and permissions, run `aws eks update-kubeconfig --name <cluster> --region <region> --profile <profile>` manually.
- ALB missing: wait a few minutes after nginx ingress creation; verify ingress/controller logs and AWS ELB console.

## Further reading
See modules/eks and modules/vpc for implementation details and variables to tune.

````// filepath: /Users/sachmil/Documents/GitHub/Terraform-eks with lb/terraform-eks-with-lb/README.md
# terraform-eks-with-lb

Minimal Terraform repo to create a VPC, EKS cluster, node group, and deploy an nginx app exposed via an ALB (Ingress).

## Repo layout
- main.tf, providers.tf, backend.tf, variables.tf, outputs.tf, versions.tf — root orchestration
- modules/
  - vpc/ — VPC, subnets, NAT, route tables
  - eks/ — EKS control plane, node group, IAM, OIDC, ALB Helm/chart support
  - apps/nginx/ — Kubernetes Deployment, Service, Ingress (creates ALB)

## Prerequisites
- Terraform >= pinned in versions.tf
- AWS CLI configured with a profile (default `personal`)
- kubectl and helm available locally
- AWS credentials with permissions to create VPC/EKS/IAM/ELB resources

## Key notes / gotchas
- Root provider blocks configure `aws`, `kubernetes`, and `helm` using outputs from `module.eks` (cluster endpoint/cert/token). module.eks must finish before providers dependent on the cluster are used.
- The repo runs a `null_resource.kubeconfig` to call `aws eks update-kubeconfig` using `var.aws_profile`. Either set `-var='aws_profile=<profile>'` or export `AWS_PROFILE`.
- ALB created by the nginx app is expected to be named `${var.cluster_name}-nginx-alb`. The root uses a `time_sleep` then a `data "aws_lb"` by name to look it up — do not remove the sleep without validating ALB naming.
- Node group defaults to a single node (desired/min/max = 1) in modules/eks/node-group.tf.

## Quickstart
1. Initialize:
   terraform init

2. Plan:
   terraform plan -var='aws_profile=<profile>' -out=tfplan

3. Apply:
   terraform apply tfplan
   or
   terraform apply -auto-approve -var='aws_profile=<profile>'

After apply the `null_resource` attempts to update `~/.kube/config`. Verify:
- kubectl get pods -A --kubeconfig ~/.kube/config
- aws elbv2 describe-load-balancers --names ${var.cluster_name}-nginx-alb --profile <profile>

## Useful variables
- aws_profile — AWS CLI profile used by update-kubeconfig (default `personal`)
- cluster_name — EKS cluster name
- subnet_ids / vpc config — set via modules/vpc outputs consumed by module.eks

## Extending
- To add more apps, follow modules/apps/nginx structure (deployment.tf, service.tf, ingress.tf, variables.tf, outputs.tf).
- To reference the cluster in new modules, consume module.eks outputs: cluster_endpoint, cluster_certificate_authority, cluster_token.

## Troubleshooting
- Kubeconfig not updated: confirm AWS CLI profile and permissions, run `aws eks update-kubeconfig --name <cluster> --region <region> --profile <profile>` manually.
- ALB missing: wait a few minutes after nginx ingress creation; verify ingress/controller logs and AWS ELB console.

## Further reading
See modules/eks and modules/vpc for implementation details and variables to tune.
