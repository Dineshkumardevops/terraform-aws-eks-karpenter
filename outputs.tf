output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "karpenter_iam_role" {
  value = aws_iam_role.karpenter_controller.arn
}
