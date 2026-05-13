# Terraform EKS with Load Balancer

Terraform project for creating an AWS VPC, EKS cluster, managed node group, and AWS Load Balancer Controller. The current deployment also includes a `cv` application exposed through an AWS ALB and a Grafana/Prometheus monitoring stack.

For background, see the related article: [Automating deployment of CV in EKS cluster with LB using Terraform](https://medium.com/@rashmil.kukreja/automating-deployment-of-cv-in-eks-cluster-with-lb-using-terraform-295b17f8ced4).

## Repository Layout

- `provider.tf` - AWS, Kubernetes, and Helm providers.
- `main.tf` - root module orchestration and kubeconfig update command.
- `variable.tf` - root input variables.
- `modules/vpc/` - VPC, public/private subnets, NAT gateway, internet gateway, route tables, and security group.
- `modules/eks/` - EKS cluster, managed node group, IAM roles/policies, OIDC provider, Kubernetes service account, and AWS Load Balancer Controller Helm release.

## Prerequisites

- Terraform installed.
- AWS CLI installed and authenticated.
- `kubectl` installed.
- `helm` installed.
- AWS permissions to create VPC, EKS, IAM, EC2, NAT Gateway, and load balancer resources.

The default region is `ap-south-1`. The default cluster name is `eks`.

## Terraform Usage

Initialize providers and modules:

```sh
terraform init
```

Create and review a plan:

```sh
terraform plan -var='aws_profile=default' -out=tfplan
```

Apply the saved plan:

```sh
terraform apply tfplan
```

Or apply directly:

```sh
terraform apply -auto-approve -var='aws_profile=default'
```

## Kubeconfig

The Terraform root module runs:

```sh
aws eks update-kubeconfig --name eks --region ap-south-1
```

To refresh kubeconfig manually:

```sh
aws eks update-kubeconfig --name eks --region ap-south-1 --profile default
```

Verify cluster access:

```sh
kubectl config current-context
kubectl get nodes
kubectl get pods -A
```

## Current Cluster Access

The current EKS cluster is:

```text
arn:aws:eks:ap-south-1:227037544501:cluster/eks
```

The kubeconfig file is stored at:

```text
~/.kube/config
```

## CV App Endpoint

The `cv` app is exposed through an AWS ALB ingress.

Check the ingress:

```sh
kubectl get ingress -n cv
```

Current load balancer endpoint:

```text
http://k8s-myappgroup-430fe4898e-912724151.ap-south-1.elb.amazonaws.com
```

Service details:

```sh
kubectl get svc cv-cv-app -n cv
kubectl get deploy,pod -n cv -l app=cv-app
```

## Grafana Access

Grafana is installed in the `cv` namespace as service `cv-grafana`.

Start a local port-forward:

```sh
kubectl -n cv port-forward svc/cv-grafana 3000:80
```

Open Grafana:

```text
http://localhost:3000
```

Default credentials for the current deployment:

```text
username: admin
password: admin
```

To retrieve credentials from Kubernetes:

```sh
kubectl get secret cv-grafana -n cv -o jsonpath='{.data.admin-user}' | base64 --decode; echo
kubectl get secret cv-grafana -n cv -o jsonpath='{.data.admin-password}' | base64 --decode; echo
```

## Useful Commands

Show cluster status:

```sh
aws eks describe-cluster --name eks --region ap-south-1 --profile default \
  --query 'cluster.{name:name,status:status,version:version,endpoint:endpoint}' \
  --output table
```

Show the AWS Load Balancer Controller:

```sh
kubectl -n kube-system get deploy,svc,sa | grep aws-load-balancer-controller
```

Show all `cv` namespace resources:

```sh
kubectl get all,ingress -n cv
```

## Key Variables

- `region` - AWS region. Default: `ap-south-1`.
- `aws_profile` - AWS CLI profile used by the kubeconfig local-exec. Default: `personal`.
- `cluster_name` - EKS cluster name. Default: `eks`.
- `cluster_version` - EKS Kubernetes version.
- `instance_types` - managed node group instance types. Default: `["t3.medium"]`.
- `ec2_ssh_key` - EC2 key pair name for worker nodes.

## Troubleshooting

If kubeconfig points to an old or deleted cluster endpoint, remove the stale context:

```sh
kubectl config get-contexts
kubectl config delete-context <old-context>
kubectl config delete-cluster <old-cluster>
kubectl config delete-user <old-user>
aws eks update-kubeconfig --name eks --region ap-south-1 --profile default
```

If the ALB endpoint is not available yet, check ingress and controller status:

```sh
kubectl get ingress -n cv
kubectl -n kube-system logs deploy/aws-load-balancer-controller
```

If Terraform fails during the kubeconfig local-exec step, make sure the selected AWS profile is valid:

```sh
aws sts get-caller-identity --profile default
terraform apply -auto-approve -var='aws_profile=default'
```

## Cleanup

To destroy all Terraform-managed infrastructure:

```sh
terraform destroy -var='aws_profile=default'
```

Review the destroy plan carefully before confirming, because this removes the EKS cluster, node group, VPC networking, IAM resources, and load balancer resources.
