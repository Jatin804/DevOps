# Terraform Built-in Functions Reference

## Overview
Terraform relies on HashiCorp Configuration Language (HCL). While it is not a general-purpose programming language (meaning you cannot write your own custom functions), it includes a robust library of built-in functions to transform data, calculate values, and validate inputs dynamically.

> **Pro-Tip:** You can test any function without writing a `.tf` file by opening your terminal and typing `terraform console`.

> **Difference-Tip:** In terraform file and console the difference is just format i.e `console = function(value)` in .tf file `terreform_variable "variable-name" { value = function("data") }`

---

## 1. String Functions
Manipulate and format text data.

* **`upper("hello")`** → `"HELLO"`
* **`lower("HELLO")`** → `"hello"`
* **`title("hello world")`** → `"Hello World"`
* **`length("hello")`** → `5`
* **`trim("  hello  ", " ")`** → `"hello"` *(Removes specific characters from start/end)*
* **`trimspace("  hello  ")`** → `"hello"` *(Removes all whitespace from start/end)*
* **`replace("hello world", "world", "Terraform")`** → `"hello Terraform"`
* **`substr("hello world", 0, 5)`** → `"hello"` *(Arguments: string, offset, length)*
* **`split(",", "a,b,c")`** → `["a", "b", "c"]` *(Separates a string into a list)*

---

## 2. Numeric Functions
Perform mathematical operations and rounding.

* **`max(1, 5, 3)`** → `5`
* **`min(1, 5, 3)`** → `1`
* **`abs(-5)`** → `5` *(Absolute value)*
* **`ceil(3.2)`** → `4` *(Rounds up)*
* **`floor(3.8)`** → `3` *(Rounds down)*
* **`round(3.14159, 2)`** → `3.14` *(Rounds to specific decimal places)*

---

## 3. Collection Functions
Query and manipulate lists, sets, and maps.

* **`length([1, 2, 3])`** → `3` *(Works on lists and maps)*
* **`concat(["a"], ["b"])`** → `["a", "b"]` *(Combines lists)*
* **`merge({"a"=1}, {"b"=2})`** → `{"a"=1, "b"=2}` *(Combines maps)*
* **`keys({"a"=1, "b"=2})`** → `["a", "b"]` *(Extracts map keys as a list)*
* **`values({"a"=1, "b"=2})`** → `[1, 2]` *(Extracts map values as a list)*
* **`contains(["a", "b"], "a")`** → `true` *(Checks if a list/set contains a value)*
* **`contains(keys({"a"=1}), "a")`** → `true` *(Correct way to check for a map key)*

---

## 4. Type Conversion Functions
Explicitly convert variables from one data type to another.

* **`tostring(123)`** → `"123"`
* **`tonumber("123")`** → `123`
* **`tobool("true")`** → `true`
* **`tolist(var.my_set)`** → Converts a set or tuple into a list.
* **`toset(["a", "b", "a"])`** → `["a", "b"]` *(Removes duplicates from a list)*

---

## 5. Time Functions
Generate and manipulate timestamps (useful for creating unique resource names).

* **`timestamp()`** → `"2024-06-01T12:00:00Z"` *(Current UTC time in ISO 8601)*
* **`timeadd(timestamp(), "1h")`** → Adds 1 hour.
* **`timeadd(timestamp(), "30m")`** → Adds 30 minutes.
* **`timeadd(timestamp(), "1d")`** → Adds 1 day.

---

## 6. File Functions
Read local files from the machine running Terraform.

* **`file("path/to/script.sh")`** → Returns the raw string contents of the file.
* **`fileexists("path/to/script.sh")`** → `true` or `false`.
* **`filebase64("path/to/key.pem")`** → Returns the file contents encoded in Base64 (frequently used for EC2 User Data).
* **`filebase64sha256("path/to/app.zip")`** → Returns a hash of the file (useful for detecting if a Lambda function payload has changed).

---

## 7. Validation Functions
Safely test logic or validate input variables.

* **`can(1 + 1)`** → `true` *(Returns true if the expression executes without error)*
* **`can(tonumber("abc"))`** → `false` *(Would normally throw an error, `can` catches it)*
* **`can(regex("^[a-z]+$", "hello"))`** → `true` *(Validates a string against a Regex pattern)*
* **`strcontains("hello world", "world")`** → `true` *(Checks for a substring)*
* **`startswith("hello world", "hello")`** → `true`
* **`endswith("hello world", "world")`** → `true`

---

## 8. Lookup Functions
Safely retrieve values from complex data structures.

* **`lookup({"a"=1, "b"=2}, "c", "default")`** → `"default"` *(Attempts to find key "c". If missing, returns the fallback "default")*
* **`element(["a", "b", "c"], 1)`** → `"b"` *(Retrieves list item by index. Wraps around if index exceeds length)*
* **`index(["a", "b", "c"], "b")`** → `1` *(Finds the numerical index of an item in a list)*