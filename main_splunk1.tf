#  Terraform to create Palo Alto Networks Panorama system in AWS

locals {
  panorama_ami       = "ami-0f5970a9ddece7cc4"    # Panorama 10.1.9 from AWS marketplace
  awslinux_ami       = "ami-094125af156557ca2"    # AMI for testing build, routes etc. 
  panorama_inst_type = "c5.4xlarge"               # PAN min recommendation
  awslinux_inst_type = "t2.small"                 # max 4 NICs
  }




resource "aws_instance" "Panorama-1" {
  ami                                 = local.panorama_ami
  #ami                                = local.awslinux_ami
  instance_type                       = local.panorama_inst_type
  #instance_type                      = local.awslinux_inst_type
  key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = false
  private_ip                          = "10.255.1.10"
  subnet_id                           = module.vpc["mgmtvpc"].intra_subnets[1]           #Panoramo AZ1 public subnet
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["mgmtvpc"].id]  
  source_dest_check                   = false
  tags = {
          Owner = "dan-via-terraform"
          Name  = "Panorama-1"
    }
}
# Add one more NIC to the Panorama instance 
resource "aws_network_interface" "eth1-1" {
  subnet_id             = module.vpc["mgmtvpc"].intra_subnets[0]                   #Pamorama AZ1 private (internal) subnet
  security_groups       = [aws_security_group.SG-allow_ipv4["mgmtvpc"].id]
  private_ips           = ["10.255.0.10"]     
    
  attachment  {
    instance            = aws_instance.Panorama-1.id
    device_index        = 1
  }
}

################
# Create one EIPs for each Panorama system for the public side, and the "Mgmt-public-subnets-RT" route table's default will be the IGW in the vpc
resource "aws_eip" "Pano1-eip-mgmt-int" {
  vpc                   = true
}

# Associate the EIPs to the public side NICs on each Panorama 
resource "aws_eip_association" "pano1-pub-assoc" {
  allocation_id         = aws_eip.Pano1-eip-mgmt-int.id
  network_interface_id  = aws_instance.Panorama-1.primary_network_interface_id
}
 
