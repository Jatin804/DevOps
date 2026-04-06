
# (Remote storing state file) Creating s3 backend to store terraform state files in s3 bucket
# Bucket has to be created manually or by CI-CD pipeline for it

terraform {
  # S3 as the backend for storing terraform state files
  backend "s3" {
    bucket = "mybucket-terraform-state-files-jatin-v1"
    # folders based on prod eg. below is for "dev" environment
    key    = "dev/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
    # preventing from concurrent modifications of the state file (S3)
    use_lockfile = true
  }

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.38.0"
    }
  }
}

provider "aws" {
    region = "ap-south-1"
}