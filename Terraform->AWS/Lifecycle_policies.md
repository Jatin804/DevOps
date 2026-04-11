# Terraform Advanced Configuration: Lifecycle Management

## Overview
This configuration demonstrates how to manipulate Terraform's standard operational behavior using `lifecycle` meta-arguments. It includes safeguards against accidental deletion, strategies for zero-downtime updates, and custom validation rules using pre- and post-conditions.

## Provider & Foundation Setup
* **Provider:** AWS (HashiCorp) version `~> 6.38.0`
* **Region:** Dynamically assigned via `var.vpc_data`.

```hcl
terraform {
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 6.38.0"
    }
  }
}

provider "aws" {
    region = var.vpc_data
}
```

## Lifecycle Meta-Arguments Deep Dive
The `lifecycle` block allows you to alter the default way Terraform creates, updates, and destroys resources.

### 1. `create_before_destroy`
By default, Terraform destroys an existing resource before creating the replacement. Setting this to `true` inverses that behavior, which is critical for zero-downtime deployments.
```hcl
lifecycle {
  create_before_destroy = true # Create new resource first, then destroy the old one
}
```

### 2. `prevent_destroy`
A crucial safeguard for stateful or critical infrastructure (like databases or main VPCs). If set to `true`, Terraform will throw an error and refuse to apply any plan that would destroy this resource.
```hcl
lifecycle {
  prevent_destroy = true # Rejects any plan that attempts to destroy this resource
}
```

### 3. `ignore_changes`
Tells Terraform to ignore differences between the configuration and the real-world infrastructure for specific attributes. This is highly useful when external systems (like an autoscaler) modify resource states.
```hcl
lifecycle {
  ignore_changes = [
    desired_capacity,  # e.g., Ignore capacity changes made by auto-scaling
    tags["LastUpdated"] # e.g., Ignore dynamic tags 
  ]
}
```

### 4. `replace_triggered_by`
Forces the replacement of a resource if a specified different resource or attribute changes.
```hcl
lifecycle {
  replace_triggered_by = [
    aws_security_group.app_sg.id  # If the Security Group ID changes, recreate this resource too
  ]
}
```

---

## Custom Condition Checks (Validation)
Terraform allows custom validation directly within the resource block to ensure compliance and prevent misconfigurations.

### 5. `precondition` (Pre-flight Checks)
Evaluated *before* the resource is created or updated. It ensures assumptions are met before making API calls.
```hcl
resource "aws_s3_bucket" "regional_validation" {
  bucket = "validated-region-bucket"

  lifecycle {
    precondition {
      # Validates that the current AWS region is in the allowed list
      condition     = contains(var.allowed_regions, data.aws_region.current.name)
      error_message = "ERROR: Can only deploy in allowed regions: ${join(", ", var.allowed_regions)}"
    }
  }
}
```

### 6. `postcondition` (Post-flight Checks)
Evaluated *after* the resource is created or updated. It validates the resulting state of the resource to ensure it meets operational or security standards.
```hcl
resource "aws_s3_bucket" "compliance_bucket" {
  bucket = "compliance-bucket"
  
  tags = {
    Environment = "production"
    Compliance  = "SOC2"
  }

  lifecycle {
    postcondition {
      # Validates that the resource successfully received a 'Compliance' tag
      condition     = contains(keys(self.tags), "Compliance")
      error_message = "ERROR: Bucket must have a 'Compliance' tag!"
    }
  }
}
```