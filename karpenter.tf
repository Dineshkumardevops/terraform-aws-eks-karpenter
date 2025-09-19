############################
# IAM Role for Karpenter Controller
############################
resource "aws_iam_role" "karpenter_controller_role" {
  name = "KarpenterControllerRole-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

############################
# IAM Role for Karpenter Nodes
############################
resource "aws_iam_role" "karpenter_node_role" {
  name = "KarpenterNodeRole-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

############################
# Admin Policy Attachments (Easy toggle ON/OFF)
############################

#  Attach admin policy to controller role
resource "aws_iam_role_policy_attachment" "karpenter_controller_admin" {
  count      = var.enable_admin_access ? 1 : 0
  role       = aws_iam_role.karpenter_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Attach admin policy to node role
resource "aws_iam_role_policy_attachment" "karpenter_node_admin" {
  count      = var.enable_admin_access ? 1 : 0
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

############################
# Outputs
############################
output "karpenter_controller_role_arn" {
  value = aws_iam_role.karpenter_controller_role.arn
}

output "karpenter_node_role_arn" {
  value = aws_iam_role.karpenter_node_role.arn
}
