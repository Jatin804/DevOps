# AWS VPC with Load Balancer and Auto Scaling Group

## Project Overview

This project demonstrates how to:

* Create a custom VPC
* Configure public subnets across multiple Availability Zones
* Launch EC2 instances using an Auto Scaling Group (ASG)
* Configure an Application Load Balancer (ALB)
* Deploy two different web pages
* Distribute traffic 50:50 using the Load Balancer

This architecture is production-style and follows AWS best practices.

**Refrence Diagram (AWS)**:
![alt text](images/vpc-example-private-subnets.png)

---

# Architecture Diagram (Logical)

```
Internet
   |
Route 53 (optional)
   |
Application Load Balancer
   |
Target Group
   |
Auto Scaling Group
   |
EC2 Instances (2 AZs)
   |
VPC In AZs
```

---

# Step 1: Create VPC

1. Go to VPC Dashboard
2. Click **Create VPC**
3. Choose **VPC and more**

Configuration:

* Name: Provide a meaningful name
* Tenancy: Default
* Below there is my selected configuration, This configuration creates two public and two private subnets across two Availability Zones for high availability., which will help to isolate instance for accessing from outside.

![alt text](<images/Screenshot%202026-02-13%20at%2012.00.04 PM.jpeg>)

After Create VPC, VPC will be created as :

![alt text](<images/Screenshot 2026-02-13 at 12.06.19 PM.jpeg>)

---

# Step 2: Internet Gateway

When creating a VPC using the “VPC and more” section, AWS automatically provisions an Internet Gateway, attaches it with VPC, and updates the route table to include a default route targeting the Internet Gateway for internet access.

---

# Step 3: Create Security Groups
Security groups can be created during ALB creation or from the Security Groups section in the VPC console.

## ALB Security Group

ALB Security Group
* HTTP (80) from 0.0.0.0/0


## EC2 Security Group

Allow:

* HTTP (Port 80) from ALB Security Group
* SSH (Port 22) from your IP

---

# Step 4: Create Launch Template

1. Go to EC2 → Launch Templates
2. Create Launch Template, The process is similar to launching a standard EC2 instance

Configuration:

* AMI: Amazon Linux 2023 or desired AMI
* Instance Type: t3.micro (Free Tier)
* Key pair: your-key.pem
* Security Group: EC2 Security Group, as it was created

## User Data Script

Paste this in User Data or configure manually:

```bash
#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd

INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)

if [[ $INSTANCE_ID == *"a" ]]; then
  echo "<h1>Web Page 1</h1>" > /var/www/html/index.html
else
  echo "<h1>Web Page 2</h1>" > /var/www/html/index.html
fi
```

---

# Step 5: Create Target Group for Load Balancer

1. Go to EC2 → Target Groups
2. Create Target Group

Configuration:

* Target type: Instance
* Protocol: HTTP
* Port: 80
* VPC: Project-VPC
* Health Check Path: /

---

# Step 6: Create Auto Scaling Group

1. Go to EC2 → Auto Scaling Groups
2. Create ASG

Configuration:

* Launch Template: previously created
![alt text](<images/Screenshot 2026-02-13 at 12.08.33 PM.jpeg>)
* VPC: Project-VPC
* Subnets: Private-Subnet-1 and Private-Subnet-2
![alt text](<images/Screenshot 2026-02-13 at 12.17.26 PM.jpeg>)
* Desired capacity: 2
* Minimum: 2
* Maximum: 4
![alt text](<images/Screenshot 2026-02-13 at 12.18.35 PM.jpeg>)
* Attach to existing Load Balancer
* Select Target Group

---
### Instances are deployed in private subnets without public IPs. The Application Load Balancer in public subnets handles incoming internet traffic and forwards it to private EC2 instances via target group.

---

# Step 7: Create Bastion Host (SSH Access)

1. To securely access private EC2 instances
2. Launch a new EC2 instance
3. Name: bastion-host or any meaningful
4. Place it in a public subnet
5. Enable Public IP
6. Attach Bastion Security Group
7. Use the same key pair

## SSH Workflow

From your local machine:

* copy key to ec2-instance\
```scp -i your-key.pem key-location-to-transfer-for-instance-connection/key.pem location ec2-instance/location-key.pem``` 
* ssh to connect to private ec2-instance\
```ssh -i your-key.pem ec2-user@<bastion-public-ip>```

From Bastion to private instance:

```ssh -i your-key.pem ec2-user@<private-instance-ip>```

This allows secure communication without exposing private instances to the internet.

---

# Step 8: Create Application Load Balancer

1. Go to EC2 → Load Balancers
2. Create Load Balancer → Application Load Balancer

Configuration:

* Scheme: Internet-facing
* Select VPC
* IP type: IPv4
* Listener: HTTP (80)
* Add AZs both subnets
* Security group: ALB Security Group
* Forward to Target Group
* Next and add instance that were started using Templates

---

# 50:50 Load Distribution Explanation

Since the Auto Scaling Group launches two instances across two Availability Zones, the Application Load Balancer distributes traffic evenly across healthy targets.

By default, ALB uses round-robin routing.

This ensures:

* Approximately 50% traffic to Web Page 1/ Instance 1
* Approximately 50% traffic to Web Page 2/ Instance 2

You can verify by:

* Opening ALB DNS name in browser
* Refresh multiple times
* Observing alternating web pages

---

# Scaling Configuration (Optional)

Add scaling policy:

* Target tracking policy
* Metric: Average CPU Utilization
* Target value: 50%

This automatically scales instances when traffic increases.

---


# Testing the Deployment

1. Copy the ALB DNS name
2. Paste in browser
3. Refresh multiple times
4. Confirm both web pages appear

---

# Cleanup

To avoid AWS charges:

1. Delete Auto Scaling Group
2. Delete Load Balancer
3. Delete Target Group
4. Terminate EC2 instances
5. Delete Launch Template
6. Delete Subnets
7. Detach and Delete Internet Gateway
8. Delete VPC