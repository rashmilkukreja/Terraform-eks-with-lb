# Kubernetes service account annotated for IAM Roles for Service Accounts.
resource "kubernetes_service_account_v1" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    # This annotation links the pod identity to the IAM role above.
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}
