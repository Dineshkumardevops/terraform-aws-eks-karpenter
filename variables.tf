variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "karpenter-demo"
}

variable "kubernetes_version" {
  default = "1.29"
}

variable "karpenter_version" {
  default = "0.35.0"
}
