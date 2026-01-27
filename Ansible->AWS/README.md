# AWS Infrastructure Automation with Ansible
This project provides a streamlined workflow for provisioning and managing AWS resources (such as EC2 instances) using Ansible. By leveraging Ansible Vault for secret management and the amazon.aws collection, you can securely automate your cloud infrastructure.

## Prerequisites
Before running the playbook, ensure your control node has the following installed:

- Python 3.x

- Ansible (Core 2.11+)

- Boto3: The AWS SDK for Python, required for Ansible to communicate with AWS APIs.


## 1. Environment Setup
#### Install Dependencies
Install the necessary Python library and the Ansible AWS collection:

```
Bash

# Install the AWS SDK for Python
pip install boto3

# Install the official AWS collection from Ansible Galaxy
ansible-galaxy collection install amazon.aws
```

#### IAM Configuration
1. Log in to the AWS Management Console.

2. Create an IAM User with "Programmatic access."

3. Permissions: Attach a policy with the minimum required permissions (e.g., AmazonEC2FullAccess).

4. Credentials: Save the Access Key ID and Secret Access Key. Do not share these or commit them to version control.


## 2. Secure Secret Management (Ansible Vault)
We use Ansible Vault to encrypt sensitive AWS credentials so they aren't stored in plain text.

#### Create a Vault Password File
Instead of typing the password every time, store a strong, random string in a local file. Ensure this file is added to your .gitignore.

```
Bash

# Generate a secure random string for the vault password
openssl rand -base64 2048 > .vault_pass
```

#### Encrypt AWS Credentials
Create an encrypted variable file to store your keys:

```
Bash

ansible-vault create group_vars/all/pass.yml --vault-password-file .vault_pass
```

#### Inside pass.yml, define your variables:
```
YAML

aws_access_key: "YOUR_ACCESS_KEY_HERE"
aws_secret_key: "YOUR_SECRET_KEY_HERE"
```

## 3. Project Structure
A clean directory structure helps maintainability:
```
Plaintext

.
├── inventory            # Server inventory file
├── group_vars/
│   └── all/
│       └── pass.yml     # Encrypted AWS credentials
├── ec2_create.yml       # Main playbook
├── .vault_pass          # Vault password (LOCAL ONLY - DO NOT COMMIT)
└── README.md
```
## 4. Usage
#### The Playbook Logic
Your playbook (ec2_create.yml) should reference the encrypted variables and use the amazon.aws.ec2_instance module.

#### Tip: Always define the region directly in your tasks or as a variable to avoid connection errors.

#### Execution
Run the playbook by pointing to your vault password file:
```
Bash

ansible-playbook ec2_create.yml --vault-password-file .vault_pass
```
#### Security Reminders
- Gitignore: Always include .vault_pass and any unencrypted .yml files in your .gitignore.

- Rotate Keys: Regularly rotate your AWS IAM keys to minimize impact in case of a leak.

- IAM Roles: For production environments running on EC2, consider using IAM Roles instead of static Access Keys for even better security.
