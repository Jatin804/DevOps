# Creating S3 bucket for storing terraform state files

terraform { 
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


resource "aws_s3_bucket" "first_bucket" {
  bucket = "my-test-bucket-v1-jatin"

  tags = {
    Name        = "My test bucket"
    Environment = "Dev"
  }
}
