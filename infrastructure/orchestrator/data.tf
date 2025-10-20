data "aws_region" "current" {}

data "aws_iam_user" "chouser" {
  user_name = "charles.houser"
}

data "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"
}

data "aws_iam_role" "eks_node" {
  name = "eks_node"
}

data "aws_iam_role" "aws_ebs_csi_driver" {
  name = "AmazonEKS_EBS_CSI_Driver"
}

data "aws_iam_role" "aws_load_balancer_controller" {
  name = "AWSLoadBalancerController"
}

data "aws_security_group" "eks_platform" {
  id = aws_eks_cluster.platform.vpc_config[0].cluster_security_group_id
}
