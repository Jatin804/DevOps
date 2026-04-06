# Terraform Versioning 
# tereaform init <- will initialize the terraform configuration and download the required providers, using cli !

terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 1.14.0"       # Latest version of the AWS provider's 1.14.x 
    }
  }
}

# Configure the AWS provider
provider "aws" {
    region = "us-west-2"          # Specify the AWS region to use
}

# Create a resource
# 1. resource name
# 2. resource local name, code reference
resource "aws_vpc" "example_name" {
    cidr_block = "10.0.0.0/16"
  
}

# example how example_name is used in aws_ec2_host resource

# resource "aws_ec2_host" "name" {
#     vpc_id = aws_vpc.example_name.id

# }

