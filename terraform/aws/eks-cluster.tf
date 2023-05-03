#create cluster
resource "aws_eks_cluster" "cratis-test-eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cratis-test-eks-role.arn


  vpc_config {
    subnet_ids = [
      aws_subnet.private-eu-central-1a.id,
      aws_subnet.private-eu-central-1b.id,
      aws_subnet.public-eu-central-1a.id,
      aws_subnet.public-eu-central-1b.id,
    ]
  }

  #kubernetes master version force, or use latest if no version is provided

  #version = "1.23"

  # #logging
  # enabled_cluster_log_types = ["api", "audit", "authenticator", "scheduler", "controllerManager"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cratis-test-eks-role-attach,
    aws_iam_role_policy_attachment.cratis-test-eks-role-attach-2,
  ]
}


# add-ons for our eks cluster 
resource "aws_eks_addon" "addons" {
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.cratis-test-eks.id
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts = "OVERWRITE"

  #  must have this depends_on block because CORE DNS can be added only when cluster and nodes are up
  depends_on = [
    aws_eks_cluster.cratis-test-eks,
    aws_eks_node_group.cratis-test-node-group,
  ]
}
