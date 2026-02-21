# Copilot / AI agent instructions — terraform-eks-creation-with-alb

Purpose: Give AI agents the minimal, actionable knowledge to modify or extend this Terraform repo.

- **Big picture**: top-level `main.tf` composes three module groups:
  - `modules/vpc` — VPC, public/private subnets, NAT/EIP, route tables ([modules/vpc/main.tf]).
  - `modules/eks` — EKS control plane and node group ([modules/eks/main.tf], [modules/eks/node-group.tf]).
  - `modules/apps/nginx` — app manifests (Deployment, Service, Ingress) that rely on ALB created via Kubernetes/Ingress resources.

- **Important outputs / integration points**:
  - Root `provider.tf` configures `aws`, `kubernetes`, and `helm` providers using outputs from `module.eks` (`cluster_endpoint`, `cluster_certificate_authority`, `cluster_token`). Code that depends on the cluster expects those outputs to be available after `module.eks` finishes.
  - After `terraform apply`, a `null_resource.kubeconfig` runs `aws eks update-kubeconfig` using `var.aws_profile` (see `main.tf`). The repo expects AWS CLI + profile present locally.
  - `modules/apps/nginx` creates an ALB that is later read via `data "aws_lb" "nginx"` using the name pattern `${var.cluster_name}-nginx-alb` (see `main.tf`). A `time_sleep` is used to wait before querying the ALB.

- **Developer workflow (what to run)**:
  - Initialize: `terraform init` in repo root.
  - Plan: `terraform plan -var='aws_profile=<profile>' -out=tfplan`
  - Apply: `terraform apply tfplan` (or `terraform apply -auto-approve -var='aws_profile=<profile>'`).
  - Requirements: AWS CLI configured, kubectl/helm available if interacting manually; `var.aws_profile` defaults to `personal`.

- **Project-specific conventions & gotchas**:
  - Modules are local relative paths under `modules/` (`vpc`, `eks`, `apps/nginx`). Follow existing variable names when extending modules (e.g., `cluster_name`, `subnet_ids`).
  - The `aws` provider block in `provider.tf` hardcodes `profile = "personal"` while `main.tf` uses `var.aws_profile` for the `aws eks update-kubeconfig` command — be cautious when changing profiles; prefer setting `AWS_PROFILE` env or updating `provider.tf` if you change `var.aws_profile`.
  - Node group defaults (single-node): `modules/eks/node-group.tf` sets `desired = 1, min = 1, max = 1`. Adjust scaling when adding tests or CI.
  - ALB detection uses `time_sleep` + `data "aws_lb"` by name; avoid refactoring this to faster polling without validating ALB naming.

- **Common edits and examples**:
  - To add a new app module, follow `modules/apps/nginx` layout: `deployment.tf`, `service.tf`, `ingress.tf`, `variables.tf`, `outputs.tf`.
  - To reference the cluster from a new module, consume `module.eks.cluster_endpoint` and related outputs; the `kubernetes` and `helm` providers are already configured at root.

- **Testing / validation tips**:
  - After `apply`, run `kubectl get pods -A --kubeconfig ~/.kube/config` (the `null_resource` attempts to update `~/.kube/config`).
  - Verify ALB existence: `aws elbv2 describe-load-balancers --names ${var.cluster_name}-nginx-alb --profile <profile>`.

- **Files to inspect when changing infra**:
  - `main.tf`, `provider.tf`, `variable.tf` (root)
  - `modules/vpc/main.tf`
  - `modules/eks/main.tf`, `modules/eks/node-group.tf`
  - `modules/apps/nginx/*` (deployment/service/ingress)

If any section is unclear or you want me to include CI/CD or role/permission specifics (IAM attachments in `modules/eks`), tell me which focus area to expand. Reply with areas to clarify or approve this file.
