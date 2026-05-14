# Downloads the official AWS Load Balancer Controller IAM policy document.
data "http" "alb_policy_json" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

# Creates the IAM policy that lets the controller manage ALB/NLB resources.
resource "aws_iam_policy" "alb_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = data.http.alb_policy_json.response_body
}

# Attaches the controller policy to the IRSA role.
resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}
