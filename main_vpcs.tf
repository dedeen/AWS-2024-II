#  Terraform to create a vpcs, as part of a larger Palo Alto Firewall PoC. 
#         https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#         https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
#         -- Dan Edeen, dan@dsblue.net, 2022  --   
#
# Build VPCs for Project
module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"

  for_each = var.app_vpcs     #App and Mgmt VPCs
    providers = {
      aws = aws.usw2  # Set region via provider alias
    }
    name              = each.value.region_dc
    cidr              = each.value.cidr
    azs               = each.value.az_list
	
    # Create subnets: private get route through NATGW, intra do not
    intra_subnets   		= each.value.vpc_subnets	
    intra_subnet_names 		= each.value.subnet_names
    enable_ipv6            	= false
    enable_nat_gateway   	= false
  
}
  
  
