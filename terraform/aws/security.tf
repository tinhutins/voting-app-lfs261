#security group to allow networking access to the Kubernetes masters
resource "aws_security_group" "cratis-test-eks-sg" {
  name        = "terraform-cratis-test-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cratis-test-eks-sg"
  }
}

# security group which controls networking access to the Kubernetes worker nodes.

resource "aws_security_group" "node-pool-sg" {
  name        = "${var.node_pool_name}-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = tomap({
    "Name"                                      = "node-pool-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

resource "aws_security_group_rule" "node-pool-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node-pool-sg.id
  source_security_group_id = aws_security_group.node-pool-sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-node-ingress-cluster-https" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node-pool-sg.id
  source_security_group_id = aws_security_group.cratis-test-eks-sg.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-node-ingress-cluster-others" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node-pool-sg.id
  source_security_group_id = aws_security_group.cratis-test-eks-sg.id
  to_port                  = 65535
  type                     = "ingress"
}

# allow the worker nodes networking access to the EKS master cluster.
resource "aws_security_group_rule" "cratis-test-eks-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cratis-test-eks-sg.id
  source_security_group_id = aws_security_group.node-pool-sg.id
  to_port                  = 443
  type                     = "ingress"
}

