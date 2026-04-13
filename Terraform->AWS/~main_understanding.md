## Terraform

### Version: 
1. Before using version of terraform, you mush test and use it.
2. Locking Version : for example version= ~>6.2.0 , it will install 6.2’s latest version ie. 6.2.13, same for version= ~>1.0, 1.10 will be installed.
3. Last part will be changed

### Remort backend:
1. Its stores terraform state file in remote location ie S3 bucket, that stores the information of backend.
2. State Locking : 
3.  State file should be isolated and backed up
4. Creating state file will not include any changes as per terraform output or might be 

### Variables:
Variables are based on purpose: 
1. Input variables -> those are defined within a function, variable “variable_name” {}
2. Output variables -> those are defined to produce an output I.e for check ID is an example, output{}
3. Local variable -> these are defined to local use but not in a function, local {}

### Variable concept: 
- Variables has a type to be defined, i.e can be string, number, bool
- Variables have precedence I.e shell variable have lower precedence then terraform variable defined in file, example below is in High to low order.
    -  any -var or -var-file options
    - .auto.tfvars or  *.auto.tfvars.json
    - terraform.tfvars.json
    - terraform.tfvars
    - Env variables
    - Using defaults 

### List, Sets, Objects, Tuples concept:
1. list(string) = [“hello”, “World”]                       list[0], list[1]
2. set(string) = [“hello”, “World”]                       for_each
``` 
3. map(string) = {
	name=“”jatin”,
	series=“Terraform”  	# each.value, each.key
	} 
```


### File Structure  & Best practices: 
Below is a best file structure that can be minimized based on conditions. 
- Can be separated for prod environments. Like dev, prod, staging etc.
```
project-root/
├── backend.tf           # Backend configuration
├── provider.tf          # Provider configurations
├── variables.tf         # Input variable definitions
├── locals.tf           # Local value definitions
├── main.tf             # Main resource definitions
├── vpc.tf              # VPC-related resources
├── security.tf         # Security groups, NACLs
├── compute.tf          # EC2, Auto Scaling, etc.
├── storage.tf          # S3, EBS, EFS resources
├── database.tf         # RDS, DynamoDB resources
├── outputs.tf          # Output definitions
├── terraform.tfvars   # Variable values, ignoring values like confidential data 
└── README.md           # Documentation
```


### Meta Arguments:
Theses are arguments which are provided (fixed) by provider ie AWS

**Index** = It’s the index of a value within a datatype,  value = Its a value of an index

### Meta arguments have types, they are:
1. Depends on (depends_on) -> in which one argument is dependent on another dependent argument, ie. One resource is waiting for other resource to provision 
2. Count  (count.index or count.value)-> Creates multiple instances of a resource based on a whole number. Each instance is tracked by an index (e.g., aws_instance.server[0]).
3. for_each: Creates multiple instances based on a map or set of strings. This is generally preferred over count for better stability when items are added or removed.


### Terraform Life Cycle:
1. Ignore Changes: (ignore) It will ignore change that will be done.
2. Create Before Destroy (create_before_destroy = false/true): Delete the existing resource after creating same new resource. 
3. Prevent Destroy (prevent_destroy = false/true): To prevent deletion of a particular resource.
4.  Replace triggered by: Replacing dependencies of a resource and update it., Like replace the ec2 instance with new ec2, if there any changes in security group
5. Pre and Post condition: Pre and post check before and after initialization a resource.


### Terraform functions: 
Terraform functions are the in-build functions in terraform and they can’t be created by us to define our own function.
They are mainly classified in various types like time, math, string, collection, conversion, file, validation and few more.

**Note:** These can be run in console (terminal) and file both,
- **Difference**:
    - Console -> function(values) 
    - File -> variable “var_name” { function_name = function(values)

### Terraform Data Sources: 
Data sources in Terraform are used for referring the existing resources that are currently present in AWS.
I.e, if we want to use the existing resource from aws, u can create a variable and filter it out using filter by name.
```
Example: 
data "aws_vpc" "vpc_example_name" {
    filter {
        name = "tag:Name"
        values = ["default"]
    }
}
```
It’s not creating it just using the references and using current resource.


### Modules in terraform:
This is simple reusable modules these are alternatives of in-build functions of terraform, that can be reused.
- They are terraform files, but in different folder, like for -> IAM, EC2 etc.. 
- They talk to main file by mentioning source = “/path” in module keywords.
- Root module act as source, and modules act as definitions, and modules to modules (i.e p2p)

There are 2 types of terraform modules:
1. Public Modules: Maintained by providers,
2. Partner Modules: Maintained by partners like. Joint collaboration with AWS/Cloud etc.
3. Custom Modules: Maintained by community I.e open source or a private agency, on there own version.



---
---
---
---
---
---
---
---
---
---
---
---
---
---




### Commands: 
1. terraform init  <- check 
2. terraform plan <- to know what terraform will perform 
3. terraform apply <- to apply the changes   (yes or what !!)
4. terraform apply —auto-approve <- to just apply without asking 
5. terraform destroy <- to delete all changes that file made
6. terraform destroy —auto-approve <- to just destroy without asking

### State file command for remote state file conf:
1. terraform state list <- List resources in state
2. terraform state show <resource_name>   <- Show detailed state information
3. terraform state rm <resource_name>   <- Remove resource from state (without destroying)
4. terraform state mv <source> <destination>     <- Move resource to different state address
5. terraform state pull       <- Pull current state and display

### Testing Commands:
1. terraform validate    <- Validate the reorganized structure
2. terraform fmt -recursive    <- Format all files consistently
3. terraform plan    <- Plan to ensure no changes
4. terraform apply    <- Apply if everything looks good


