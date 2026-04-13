# Terraform Architecture: Data Sources

## Overview
While `resource` blocks *create* infrastructure, `data` blocks *read* infrastructure. Data sources act as APIs, allowing Terraform to query your cloud provider for existing resources (like AMIs, VPCs, or certificates) that were created outside of your current Terraform workspace, perhaps manually or by another team. This allows you to dynamically reference their IDs without hardcoding them.

## Architecture & Resources
* **Provider:** AWS (`ap-south-1`)
* **Data Sources (Read-Only):** * 1x VPC
  * 1x Subnet
  * 1x Amazon Machine Image (AMI)
* **Resources (Created):** 1x EC2 Instance

---

## Code Breakdown

### 1. Fetching an Existing VPC
This block queries AWS for the default VPC in the specified region.

```hcl
# Queries AWS for the region's default VPC
data "aws_vpc" "vpc_example_name" {
    default = true 
}
```
* **Mechanics:** `data "<PROVIDER_TYPE>" "<LOCAL_NAME>"`. Unlike a resource block, this will not create a VPC. It simply finds the existing one and pulls all of its attributes (like its ID, CIDR block, etc.) into Terraform's memory.

### 2. Fetching a Subnet (With Dependencies)
This block queries for a specific Subnet, utilizing the ID of the VPC we just fetched.

```hcl
data "aws_subnet" "subnet_example" {
    # Filters the search to a specific VPC using the data source above
    vpc_id = data.aws_vpc.vpc_example_name.id
    
    filter {
        name   = "tag:Name"
        values = ["subnet-1"]
    }
}
```
* **`filter` block:** Used to narrow down the search query. Here, it looks for a subnet strictly named "subnet-1".
* **`vpc_id`:** By referencing `data.aws_vpc...`, we ensure Terraform only looks for "subnet-1" *inside* our default VPC, preventing errors if another "subnet-1" exists elsewhere.

### 3. Fetching the Latest AMI Dynamically
Hardcoding AMI IDs is dangerous because they frequently change due to security patches. This data source dynamically searches for the latest Amazon Linux 2 image every time the code runs.

```hcl
data "aws_ami" "ami_example" {
    most_recent = true
    owners      = ["amazon"] # Ensures we only get official AWS images
    
    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"] # The '*' acts as a wildcard for version numbers
    }
    
    filter {
      name   = "virtualization-type"
      values = ["hvm"]
    }
}
```

### 4. Deploying the Resource Using Data
Finally, we use the `aws_instance` resource block to actually build a server, plugging in the dynamically fetched IDs from our `data` sources.

```hcl
resource "aws_instance" "instance_example" {
    # Referencing the data sources instead of hardcoding 'ami-xxxxxx' or 'subnet-xxxxxx'
    ami           = data.aws_ami.ami_example.id
    subnet_id     = data.aws_subnet.subnet_example.id
    
    instance_type = "t2.micro"
    
    tags = {
        Name = "example-instance"
    }
}
```