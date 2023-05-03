# terraform state and required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.59.0"
    }
  }

  backend "local" {

  }

  # backend "http" {
  #   address        = "https://gitlab1.cratis.cc/api/v4/projects/94/terraform/state/aws-eks-iac"
  #   lock_address   = "https://gitlab1.cratis.cc/api/v4/projects/94/terraform/state/aws-eks-iac/lock"
  #   unlock_address = "https://gitlab1.cratis.cc/api/v4/projects/94/terraform/state/aws-eks-iac/lock"
  #   username       = "thutinski"
  #   password       = "glpat-Q-aeE4pmXDq1HG3nassA"
  #   lock_method    = "POST"
  #   unlock_method  = "DELETE"
  #   retry_wait_min = "5"
  # }
}
# Configure the AWS Provider
provider "aws" {
  region = var.region
  # access_key = var.access_key
  # secret_key = var.secret_key
}

#list of AWS Availability Zones which can be accessed by an AWS account within the region configured in the provider.
data "aws_availability_zones" "available" {
  state = "available"
}

