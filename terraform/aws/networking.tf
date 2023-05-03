# create a vpc
resource "aws_vpc" "main" {
  cidr_block       = var.main_vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name                                        = "main",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  }

  enable_dns_hostnames = true
}

# provide internet access for services,we need to have internet gateway, attached to our vpc, internet gateway is a virtual router that connects a VPC to the internet.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}

# for NAT allocate public IP address = elastic IP, in production maybe create 2 elastic IP and nat gateways for HA
resource "aws_eip" "nat" {
  vpc = true
  tags = {
    "Name" = "nat"
  }

  depends_on = [
    aws_internet_gateway.gw
  ]
}

#also create NAT gateway to allow services connecting to the internet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-eu-central-1a.id

  tags = {
    Name = "terraform NAT gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

# to meet eks requirements we need to have 2 public and 2 private subnets in different Availability Zones
resource "aws_subnet" "private-eu-central-1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private-eu-central-1a_cidr
  availability_zone = var.av_zone-1a

  #add tags required by EKS to function properly (https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/)
  tags = {
    "Name" = "private-eu-central-1a"
    #To allow Kubernetes to use your private subnets for internal load balancers, tag all private subnets in your VPC with the following key-value pair:
    "kubernetes.io/role/internal-elb" = "1"
    #For public and private subnets used by load balancer resources. Tag all public and private subnets that your cluster uses for load balancer resources with the following key-value pair:
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "private-eu-central-1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private-eu-central-1b_cidr
  availability_zone = var.av_zone-1b

  tags = {
    "Name"                                      = "private-eu-central-1b"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "public-eu-central-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public-eu-central-1a_cidr
  availability_zone       = var.av_zone-1a
  map_public_ip_on_launch = true
  #if kubernetes worker needs public ip, uncomment below line

  #map_public_ip_on_launch = true

  #add tags required by EKS to function properly (https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/)
  tags = {
    "Name" = "public-eu-central-1a"
    #To allow Kubernetes to use only tagged subnets for external load balancers, tag all public subnets in your VPC with the following key-value pair:
    "kubernetes.io/role/elb" = "1"
    #For public and private subnets used by load balancer resources. Tag all public and private subnets that your cluster uses for load balancer resources with the following key-value pair:
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "public-eu-central-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public-eu-central-1b_cidr
  availability_zone       = var.av_zone-1b
  map_public_ip_on_launch = true
  tags = {
    "Name"                                      = "public-eu-central-1b"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

#routing tables and associating subnets with them (all routes that determine where network traffic is directed from our subnet/gateway)

#private routing table with a default route to nat gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
    cidr_block     = "0.0.0.0/0"
  }
  tags = {
    Name = "private"
  }
}

# public routing table with a default route to the internet gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public"
  }
}

#associate subnets with routing tables
resource "aws_route_table_association" "private-eu-central-1a" {
  subnet_id      = aws_subnet.private-eu-central-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-eu-central-1b" {
  subnet_id      = aws_subnet.private-eu-central-1b.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "public-eu-central-1a" {
  subnet_id      = aws_subnet.public-eu-central-1a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public-eu-central-1b" {
  subnet_id      = aws_subnet.public-eu-central-1b.id
  route_table_id = aws_route_table.public.id
}
