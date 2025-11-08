data "aws_iam_policy" "eks_ebs_csi_driver" {
  name = "AmazonEBSCSIDriverPolicy"
}

data "aws_iam_policy" "eks_worker_node_policy" {
  name = "AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "ec2_container_registry_read_only" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "ec2_container_registry_pull_only" {
  name = "AmazonEC2ContainerRegistryPullOnly"
}

data "aws_iam_policy" "eks_cluster_policy" {
  name = "AmazonEKSClusterPolicy"
}

data "aws_caller_identity" "current" {}

data "aws_lb" "platform" {
  name = "platform"
}