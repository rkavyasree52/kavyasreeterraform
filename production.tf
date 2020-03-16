# vpc.tf 
# Create VPC/Subnet/Security Group/Network ACL
provider "aws" {
  #access_key = var.access_key 
  #secret_key = var.secret_key
  profile = "default"
  region     = var.region
}
# create the VPC
resource "aws_vpc" "My_VPC_prod" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy 
  enable_dns_support   = var.dnsSupport 
  enable_dns_hostnames = var.dnsHostNames
tags = {
    Name = "My prodVPC"
}
} # end resource
# create the Subnet
resource "aws_subnet" "My_VPC_prodSubnet" {
  vpc_id                  = aws_vpc.My_prodVPC.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP 
  availability_zone       = var.availabilityZone
tags = {
   Name = "My VPC prodSubnet"
}
} # end resource
# Create the Security Group
resource "aws_security_group" "My_VPC_prodSecurity_Group" {
  vpc_id       = aws_vpc.My_prodVPC.id
  name         = "My VPC prodSecurity Group"
  description  = "My VPC prodSecurity Group"
  
  # allow ingress of port 22
  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  } 
  
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
   Name = "My VPC prodSecurity Group"
   Description = "My VPC prodSecurity Group"
}
} # end resource
# create VPC Network access control list
resource "aws_network_acl" "My_VPC_prodSecurity_ACL" {
  vpc_id = aws_vpc.My_prodVPC.id
  subnet_ids = [ aws_subnet.My_VPC_prodSubnet.id ]
# allow ingress port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock 
    from_port  = 22
    to_port    = 22
  }
  
  # allow ingress port 80 
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock 
    from_port  = 80
    to_port    = 80
  }
  
  # allow ingress ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }
  
  # allow egress port 22 
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 22 
    to_port    = 22
  }
  
  # allow egress port 80 
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 80  
    to_port    = 80 
  }
 
  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }
tags = {
    Name = "My VPC prodACL"
}
} # end resource
# Create the Internet Gateway
resource "aws_internet_gateway" "My_VPC_prodGW" {
 vpc_id = aws_vpc.My_VPC.id
 tags = {
        Name = "My VPC prodInternet Gateway"
}
} # end resource
# Create the Route Table
resource "aws_route_table" "My_VPC_prodroute_table" {
 vpc_id = aws_vpc.My_prodVPC.id
 tags = {
        Name = "My VPC prodRoute Table"
}
} # end resource
# Create the Internet Access
resource "aws_route" "My_VPC_prodinternet_access" {
  route_table_id         = aws_route_table.My_VPC_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.My_VPC_GW.id
} # end resource
# Associate the Route Table with the Subnet
resource "aws_route_table_association" "My_VPC_prodassociation" {
  subnet_id      = aws_subnet.My_VPC_Subnet.id
  route_table_id = aws_route_table.My_VPC_route_table.id
} # end resource
resource "aws_instance" "web" {
  ami = "ami-0e2ff28bfb72a4e45"
  availability_zone   = "us-east-1a"
  instance_type = "t2.micro"
  key_name = "newlearning"  # provide the name of your key avaliable in AWS account with out .pem extension( just key name)
  subnet_id = "${aws_subnet.My_VPC_prodSubnet.id}" 
  tags = {
    Name = "HelloWorld1"
  }
  security_groups = [ "${aws_security_group.My_VPC_prodSecurity_Group.id}" ]
  associate_public_ip_address = true
}
terraform {
  backend "s3" {
  encrypt = true
  bucket = "kavyaprodterra"
  dynamodb_table = "terraform-state-lock-dynamo"  
  region = "us-east-1"
  key = "aws.prodution"


# end vpc.tf
