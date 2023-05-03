# imported manually created service account for terraform
# resource "aws_iam_user" "sa-terraform" {
#   name                 = "sa-terraform"
#   path                 = "/"
#   permissions_boundary = "arn:aws:iam::aws:policy/AdministratorAccess"
#   tags                 = {}
#   tags_all             = {}
# }

#EKS CLUSTER ROLE, eks needs to have role binded to allow the Kubernetes control plane to manage AWS resources on your behalf
resource "aws_iam_role" "cratis-test-eks-role" {
  name = "cratis-test-eks-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}
#data for required policies on eks
data "aws_iam_policy" "AmazonEKSClusterPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
data "aws_iam_policy" "AmazonEKSVPCResourceController" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}
#attach required policies to eks role, Kubernetes requires Ec2:CreateTags permissions to place identifying information on EC2 resources including but not limited to Instances, Security Groups, and Elastic Network Interfaces
resource "aws_iam_role_policy_attachment" "cratis-test-eks-role-attach" {
  role       = aws_iam_role.cratis-test-eks-role.name
  policy_arn = data.aws_iam_policy.AmazonEKSClusterPolicy.arn
}
resource "aws_iam_role_policy_attachment" "cratis-test-eks-role-attach-2" {
  role       = aws_iam_role.cratis-test-eks-role.name
  policy_arn = data.aws_iam_policy.AmazonEKSVPCResourceController.arn
}

# NODE GROUP ROLE, IAM role allowing Kubernetes to access other AWS services
resource "aws_iam_role" "cratis-test-eks-nodes-role" {
  name = "cratis-test-nodes-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "AmazonEKSWorkerNodePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "AmazonEKS_CNI_Policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#attach required policies to nodes role
resource "aws_iam_role_policy_attachment" "cratis-test-nodes-role-attach" {
  role       = aws_iam_role.cratis-test-eks-nodes-role.name
  policy_arn = data.aws_iam_policy.AmazonEKSWorkerNodePolicy.arn
}

resource "aws_iam_role_policy_attachment" "cratis-test-nodes-role-attach-2" {
  role       = aws_iam_role.cratis-test-eks-nodes-role.name
  policy_arn = data.aws_iam_policy.AmazonEKS_CNI_Policy.arn
}

resource "aws_iam_role_policy_attachment" "cratis-test-nodes-role-attach-3" {
  role       = aws_iam_role.cratis-test-eks-nodes-role.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
}

# An instance profile is a container for an IAM role that you can use to pass role information to an EC2 instance when the instance starts.
resource "aws_iam_instance_profile" "node-pool-instance-profile" {
  name = "terraform-eks-node-pool-instance-profile"
  role = aws_iam_role.cratis-test-eks-nodes-role.name
}

#ssh key-pair create with terraform for connecting to ec2 nodes
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-key-pair"
}