region                     = "eu-central-1"
cluster_name               = "cratis-test-eks"
main_vpc_cidr              = "10.0.0.0/16"
private-eu-central-1a_cidr = "10.0.0.0/19"
private-eu-central-1b_cidr = "10.0.32.0/19"
public-eu-central-1a_cidr  = "10.0.64.0/19"
public-eu-central-1b_cidr  = "10.0.96.0/19"
av_zone-1a                 = "eu-central-1a"
av_zone-1b                 = "eu-central-1b"

# Node pool variables here are valid settings (https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html)
node_pool_name       = "cratis-test-node-pool"
node_pool_node_count = 1
node_pool_ami_type   = "AL2_x86_64"
#spot for testing/cheaper but aws can take them away at any time, change to on_demand for production
capacity_type           = "SPOT"
node_pool_instance_type = ["t2.large"]
node_pool_disk_size_gb  = "30"
