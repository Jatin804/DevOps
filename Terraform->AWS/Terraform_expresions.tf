# Terraform Expresions 
# 1. Conditional Expresons (True/False)
# Example:

# --> ( condition ? true_value : false_value )
# --> var.env == dev ? var.instance_type = "t2.micro" : var.instance_type = "t2.large"

resource "aws_instance" "example_var_ins" {
  ami = "ami-05d2d839d4f73aafb"
  count = 1
  # instance_type = "t3.micro"
  instance_type = var.environment == "dev" ? "t2.micro" : "t3.micro"  # if dev then t2.micro else t2.large

}


# 2. Dynamic Blocks (To write a nested block with multiple values)
# security group rule, That can be used multiple times 

# Generates multiple nested blocks within a resource based on a collection (list or map). Eliminates the need to repeat similar block configurations.

dynamic "block_name" {
    for_each = var.collection
    content {
        # Block configuration using each.key and each.value
    }
}

# 3. Splat Expresions (Retrieve multiple values from a single line)
# Mostly used to retrieve multiple values from a list of resources.

all_instance_ids = aws_instance.example[*].id

output "instances" {
  value = aws_instance.example[*].id
}


