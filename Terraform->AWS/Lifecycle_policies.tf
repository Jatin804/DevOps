# Example of Terraform configuration for AWS VPC with lifecycle management not for real use case.


terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.38.0"
    }
  }
}

provider "aws" {
    region = var.vpc_data
}

# example security group
resource "aws_security_group" "app_sg" {
  name = "app-security-group"
  # ... security rules ...
}


resource "aws_vpc" "vpc_main" {
    cidr_block = "10.0.0.0/16"    # Change in value to apply create_before_destroy lifecycle
    tags = {
        Name = "vpc_main"
    }

    lifecycle {
      # 1. Create Before Destroy
      create_before_destroy = false   # This will ensure that the existing VPC is not destroyed before the new one is created.

      # 2. Prevemt destroy
      prevent_destroy = true         # This will prevent the VPC from being destroyed accidentally.

      # 3. Ignore changes
      ignore_changes = [
      desired_capacity,  # Ignore capacity changes by auto-scaling
      load_balancers,    # Ignore if added externally
      ]

      # 4. Replace triggered by
      replace_triggered_by = [
        aws_security_group.app_sg.id  # Replace instance when SG changes
      ]

    }
}

# 5. Example of precondition in lifecycle to validate region before creating resource
resource "aws_s3_bucket" "regional_validation" {
  bucket = "validated-region-bucket"

  lifecycle {
    precondition {
      condition     = contains(var.allowed_regions, data.aws_region.current.name)
      error_message = "ERROR: Can only deploy in allowed regions: ${join(", ", var.allowed_regions)}"
    }
  }
}


# 6. Example of postcondition in lifecycle to ensure tags are applied after creation
resource "aws_s3_bucket" "compliance_bucket" {
  bucket = "compliance-bucket"

  tags = {
    Environment = "production"
    Compliance  = "SOC2"
  }

  lifecycle {
    postcondition {
      condition     = contains(keys(self.tags), "Compliance")
      error_message = "ERROR: Bucket must have a 'Compliance' tag!"
    }

    postcondition {
      condition     = contains(keys(self.tags), "Environment")
      error_message = "ERROR: Bucket must have an 'Environment' tag!"
    }
  }
}
