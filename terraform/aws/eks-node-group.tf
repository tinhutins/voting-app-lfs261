
# Provision and optionally update an Auto Scaling Group of Kubernetes worker nodes compatible with EKS.
resource "aws_eks_node_group" "cratis-test-node-group" {
  cluster_name    = aws_eks_cluster.cratis-test-eks.name
  node_group_name = var.node_pool_name
  node_role_arn   = aws_iam_role.cratis-test-eks-nodes-role.arn

  remote_access {
    ec2_ssh_key = "tf-key-pair"
    #source_security_group_ids = "some-group"
  }

  # #we add only private IPs to nodes
  # subnet_ids = [
  #   aws_subnet.private-eu-central-1a.id,
  #   aws_subnet.private-eu-central-1b.id,
  # ]

  #for test add public IPs to nodes 
  subnet_ids = [
    aws_subnet.public-eu-central-1a.id,
    aws_subnet.public-eu-central-1b.id,
  ]

  ami_type       = var.node_pool_ami_type
  instance_types = var.node_pool_instance_type
  capacity_type  = var.capacity_type
  disk_size      = var.node_pool_disk_size_gb

  #autoscaling
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  # add labels to instruct kubernetes scheduler to use a particular node group by using affinity or node selector
  #labels = {
  #  role = "general"
  #}

  # optionally add taints to allow node to repel a set of pods

  #optionalyy add launch_template block for custom configuration...for example adding additional disk to workers

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.cratis-test-nodes-role-attach,
    aws_iam_role_policy_attachment.cratis-test-nodes-role-attach-2,
    aws_iam_role_policy_attachment.cratis-test-nodes-role-attach-3,
    aws_eks_cluster.cratis-test-eks,
    aws_key_pair.tf-key-pair,
  ]
}
