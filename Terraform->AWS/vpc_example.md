### The Terraform Code (`main.tf`)

```hcl
# 1. Provider Configuration
provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

# 2. Create the VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# 3. Create a Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true # Automatically assign public IPs to instances

  tags = {
    Name = "public-subnet"
  }
}

# 4. Create a Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet"
  }
}

# 5. Create an Internet Gateway (IGW)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

# 6. Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

# 7. Create a NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id # Must be placed in a public subnet

  tags = {
    Name = "main-nat-gw"
  }

  # Ensure the IGW is created before the NAT Gateway
  depends_on = [aws_internet_gateway.igw]
}

# 8. Create a Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# 9. Create a Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# 10. Associate the Public Subnet with the Public Route Table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 11. Associate the Private Subnet with the Private Route Table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}
```

---

### Step-by-Step Explanation

Here is exactly what each block of code is doing:

**1. Provider Configuration**
This tells Terraform that you are building infrastructure on AWS and specifies the region (`us-east-1`) where your resources will be deployed. 

**2. Create the VPC (`aws_vpc`)**
This is the foundational network boundary. 
* `cidr_block`: Sets the IP range for the entire VPC (e.g., `10.0.0.0/16` gives you 65,536 IP addresses).
* `enable_dns_support` & `enable_dns_hostnames`: Allows resources inside the VPC to have human-readable DNS names instead of just IP addresses.

**3. Create a Public Subnet (`aws_subnet`)**
A subnet is a smaller chunk of your VPC. 
* We place this in a specific Availability Zone (`us-east-1a`). 
* `map_public_ip_on_launch = true`: This is crucial. It ensures that any EC2 instance launched in this subnet automatically gets a public IP address so it can communicate with the internet.

**4. Create a Private Subnet (`aws_subnet`)**
This is another chunk of your VPC, but for backend systems (like databases) that should never be directly accessible from the outside world. It does not map public IPs.

**5. Create an Internet Gateway (`aws_internet_gateway`)**
The Internet Gateway (IGW) acts as the front door for your VPC. Without it, nothing inside the VPC can talk to the public internet, and the internet cannot talk to your public resources.

**6. Create an Elastic IP (`aws_eip`)**
A NAT Gateway requires a static, unchanging public IP address to function. The Elastic IP (EIP) provides this. 

**7. Create a NAT Gateway (`aws_nat_gateway`)**
Resources in your **private subnet** don't have public IPs, but they often still need internet access to download updates or patches. The NAT (Network Address Translation) Gateway sits in the **public subnet**, takes outbound requests from private resources, and forwards them to the internet on their behalf. 
* *Note the `depends_on`: This ensures Terraform doesn't try to build the NAT Gateway until the Internet Gateway is fully active.*

**8. Create a Public Route Table (`aws_route_table`)**
A route table acts like a GPS for network traffic. This public route table has a specific rule (`route`): it directs all traffic destined for the outside world (`0.0.0.0/0`) to the **Internet Gateway**.

**9. Create a Private Route Table (`aws_route_table`)**
This is the GPS for your private subnet. Its rule directs all outbound internet traffic (`0.0.0.0/0`) to the **NAT Gateway** instead of the Internet Gateway.

**10 & 11. Route Table Associations (`aws_route_table_association`)**
Finally, creating route tables isn't enough; you have to explicitly attach them to your subnets. 
* Step 10 links the public subnet to the public route table.
* Step 11 links the private subnet to the private route table. 

### How to use this code:
1. Save the code in a file named `main.tf`.
2. Open your terminal in that directory and run `terraform init` to download the AWS provider.
3. Run `terraform plan` to see exactly what Terraform intends to build.
4. Run `terraform apply` to provision the infrastructure in your AWS account.