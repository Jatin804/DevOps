# Terraform Architecture: Variables, Locals, and Data Types

## Overview
This reference guide breaks down how Terraform handles data routing. It covers the difference between external inputs (`variables`), internal computations (`locals`), and exported results (`outputs`), alongside a comprehensive look at Terraform's structural data types.

---

## 1. Core Data Routing Concepts

### Input Variables (`variable`)
Think of these as function parameters. They allow you to pass dynamic values into your Terraform modules from the outside (via the CLI, a `.tfvars` file, or environment variables) so you don't have to hardcode everything.

```hcl
# Define the variable (usually in variables.tf)
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

# Use the variable (usually in main.tf)
resource "aws_s3_bucket" "demo" {
  bucket = "my-company-${var.environment}-bucket" # Usage requires the 'var.' prefix
}
```

### Local Values (`locals`)
Think of these as internal, computed variables. Unlike input variables, locals *can* reference other variables, resources, or functions to create complex, reusable expressions.

```hcl
locals {
  # Combines a static string, a variable, and an output from a random_string resource
  full_bucket_name = "${var.environment}-terraform-demo-${random_string.suffix.result}"
  
  common_tags = {
    Environment = var.environment
    Project     = "Terraform-Demo"
  }
}

# Usage requires the 'local.' prefix
resource "aws_s3_bucket" "demo" {
  bucket = local.full_bucket_name
  tags   = local.common_tags
}
```

### Outputs (`output`)
Outputs act like return values for your Terraform configuration. They print useful information to the console after a successful deployment and can be queried later using the CLI.

```hcl
output "bucket_name" { 
  description = "The generated name of the S3 bucket"
  value       = aws_s3_bucket.demo.bucket
}
```

---

## 2. Collection and Structural Data Types

### `list`
An ordered sequence of values of the *same type*. Duplicates are allowed.

```hcl
variable "allowed_instance_types" {
  type    = list(string)      
  default = ["t2.micro", "t3.micro", "t3.micro"] # Duplicates permitted
}

# Accessed via zero-based index
output "first_instance_type" {
  value = var.allowed_instance_types[0] # Returns "t2.micro"
}
```

### `set`
An unordered collection of *unique* values of the same type. Terraform automatically removes duplicates.

```hcl
variable "allowed_regions" {
  type    = set(string)      
  default = ["us-east-1", "us-west-2", "us-east-1"] # Stored internally as ["us-east-1", "us-west-2"]
}

# Sets cannot be accessed by an index (e.g., [0]). 
# You must convert a set to a list first if you need a specific element.
output "allowed_regions_list" {
  value = tolist(var.allowed_regions)  
}
```

### `map`
A collection of key-value pairs, where all keys are strings, and all values must be of the *same type*.

```hcl
variable "tags" {
  type = map(string)
  default = {
    "Environment" = "staging"
    "Name"        = "Terraform-Demo"
    "Creator"     = "Sai"
  }
}

# Usage
resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name
  tags   = var.tags  
}
```

### `tuple`
Similar to a list, but enforces a strict sequence of *different types*. The length is fixed based on the definition.

```hcl
# A tuple requiring exactly: one number, one string, and one number, in that order.
variable "values" {
  type    = tuple([number, string, number])
  default = [42, "Hello", 3.14]
}

# A complex tuple containing specific objects
variable "instance_configs" {
  type = tuple([
    object({ instance_type = string, ami_id = string }),
    object({ instance_type = string, ami_id = string })
  ])
  
  default = [
    { instance_type = "t2.micro", ami_id = "ami-12345678" },
    { instance_type = "t3.micro", ami_id = "ami-87654321" }
  ]
}
```

### `object`
A complex structural type that groups multiple attributes together, allowing for mixed types under named keys (similar to a struct or a JSON object).

```hcl
variable "instance_config" {
  type = object({
    instance_type = string
    ami_id        = string
    tags          = map(string)
  })
  
  default = {
    instance_type = "t2.micro"
    ami_id        = "ami-12345678"
    tags          = {
      Environment = "staging"
      Name        = "Terraform-Demo-Instance"
    }
  }
}

# Accessed using dot notation
resource "aws_instance" "demo" {
  instance_type = var.instance_config.instance_type
  ami           = var.instance_config.ami_id
  tags          = var.instance_config.tags
}
```