# Terraform Meta-Arguments: Iteration and Dependencies

## Overview
This configuration demonstrates how to efficiently scale infrastructure and control execution order using Terraform's meta-arguments. Instead of writing separate resource blocks for multiple identical resources, it utilizes `count` and `for_each` for iteration, and introduces `depends_on` to establish explicit resource dependencies.

## Architecture & Resources
* **Variables:** * 1x `list(string)` for sequential iteration.
  * 1x `set(string)` for unique, key-based iteration.
* **Storage:** 4x AWS S3 Buckets deployed across two distinct resource blocks.

---

## Code Breakdown

### 1. Defining Input Variables (List vs. Set)
Terraform handles collections differently depending on their type, which directly impacts how you iterate over them.

```hcl
# A 'list' is an ordered sequence of values, accessed by an index (0, 1, 2...).
variable "bucket_names" {
    description = "List of S3 bucket names to create"
    type        = list(string)
    default     = ["my-unique-bucket-jatin-v1-alpha-v1", "my-unique-bucket-jatin-v2-beta"]
}

# A 'set' is an unordered collection of unique values.
variable "bucket_set" {
    description = "Set of S3 bucket names to create"
    type        = set(string)
    default     = ["my-unique-bucket-jatin-v1-alpha-v1", "my-unique-bucket-jatin-v2-beta"]
}
```

### 2. The `count` Meta-Argument
The `count` meta-argument is the simplest way to create multiple identical resources. It accepts a whole number and creates that many instances of the resource.

```hcl
resource "aws_s3_bucket" "buckets" {
    count  = 2
    bucket = var.bucket_names[count.index] 
}
```
* **Mechanics:** Because `count` creates an ordered list of resources, Terraform provides the `count.index` object (starting at `0`). Here, it is used to pull the corresponding string from the `bucket_names` list to name the S3 buckets.
* **Warning:** If you remove an item from the middle of a `list` used with `count`, Terraform will shift all subsequent indexes, potentially causing unintended resource destruction and recreation.

### 3. The `for_each` Meta-Argument
`for_each` is generally preferred over `count` for collections because it maps resources to unique keys rather than sequential index numbers, making infrastructure updates much safer.

```hcl
resource "aws_s3_bucket" "buckets2" {
    for_each = var.bucket_set
    bucket   = each.value  

    depends_on = [aws_s3_bucket.buckets] 
}
```
* **Mechanics:** It accepts a `map` or a `set` of strings. In this block, it iterates over `var.bucket_set`. 
* **`each.key` and `each.value`:** When iterating over a `set`, the `each.key` and `each.value` are identical (the string itself). Here, `each.value` provides the bucket name.

### 4. Explicit Dependencies (`depends_on`)
Terraform usually maps dependencies automatically based on resource references (e.g., passing a VPC ID to an EC2 instance). However, when a hidden dependency exists that Terraform cannot "see" in the code, you must define it explicitly.

```hcl
    depends_on = [aws_s3_bucket.buckets] 
```
* **Mechanics:** By adding this to the `buckets2` block, Terraform is forced to wait until all instances of `aws_s3_bucket.buckets` are fully created before it even begins attempting to create `buckets2`.