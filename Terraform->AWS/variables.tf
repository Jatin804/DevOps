#------------------------------------------------------------------------concept
# Just a concept, Only for how to use

# Local Variable
# Values you provide to Terraform - like function parameters
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

#------------------------------------------------------------------------local

# Internal computed values - like local variables in programming
locals {
  common_tags = {
    Environment = var.environment
    Project     = "Terraform-Demo"
  }
  
  full_bucket_name = "${var.environment}-${var.bucket_name}-${random_string.suffix.result}"
}

#------------------------------------------------------------------------output

# output the local variable, can be used to check the computed value
# creating an output.tf file to check is most optimal
output "bucket_name" { 
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.demo.bucket
}
# Output:
# bucket_name = "demo-terraform-demo-bucket-abc123"

#------------------------------------------------------------------------define

# Just a concept, Only for how to use varible
# Define in variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "my-terraform-bucket"
}

#------------------------------------------------------------------------use_case

# Reference with var. prefix in main.tf
resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name  # Using input variable
  
  tags = {
    Environment = var.environment  # Using input variable
  }
}

#------------------------------------------------------------------------list

# List variables example (duplicates are allowed)
variable "allowed_instance_types" {
  description = "List of allowed EC2 instance types"
  type        = list(string)      # type mentioning it's a list of strings
  default     = ["t2.micro", "t3.micro", "t3.micro"]
}
# Accessinng a list element
output "value_of_first_instance_type" {
  value = var.allowed_instance_types[0]
}

#------------------------------------------------------------------------set

# Set variables example (duplicates are not allowed)
variable "allowed_regions" {
  description = "List of allowed AWS regions"
  type        = set(string)      # type mentioning it's a list of strings
  default     = ["us-east-1", "us-west-2"]  # duplicates will be removed
}
# when we have to access the set's value, we need to convert it into a list
# Example below   -> to access the elememts of set, we need to convert it into a list
output "allowed_regions_list" {
  value = tolist(var.allowed_regions)  # Convert set to list for output
}

#------------------------------------------------------------------------map

variable "tags" {
  type = map(string)
  default = {
    "Environment" = var.environment
    Name        = "Terraform-Demo"
    Creator     = "Sai"
  }
  
}
# Use 
resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name
  
  tags = var.tags  # Using the map variable for tags
}

#------------------------------------------------------------------------tuple

# Its like a set but it can have similar object variable.

# simple class for understanding
variable "values" {
  type = tuple([ number, string, number ])
  default = [ 42, "Hello", 3.14 ]
}

# real class
variable "instance_configs" {
  type = tuple([
    object({
      instance_type = string
      ami_id       = string
    }),
    object({
      instance_type = string
      ami_id       = string
    })
  ])
  
  default = [
    {
      instance_type = "t2.micro"
      ami_id       = "ami-12345678"
    },
    {
      instance_type = "t3.micro"
      ami_id       = "ami-87654321"
    }
  ]
}

# Use 
resource "aws_instance" "demo" {
  count         = length(var.instance_configs)
  instance_type = var.instance_configs[count.index].instance_type
  ami           = var.instance_configs[count.index].ami_id
}


#------------------------------------------------------------------------object

# A cluster of variables that grouped together
# Object can have different types of variables inside it, and we can access them with dot notation
variable "instance_config" {
  type = object({
    instance_type = string
    ami_id       = string
    tags         = map(string)
  })
  
  default = {
    instance_type = "t2.micro"
    ami_id       = "ami-12345678"
    tags         = {
      Environment = var.environment
      Name        = "Terraform-Demo-Instance"
    }
  }
}

# Use
resource "aws_instance" "demo" {
  instance_type = var.instance_config.instance_type
  ami           = var.instance_config.ami_id
  
  tags = var.instance_config.tags
}
