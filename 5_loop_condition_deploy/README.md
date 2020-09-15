# Loops, Conditional Expressions and Zero-Downtime Deployment
## Count

### Referencing the `count` index
Format: `count.index`
Example: `user = "user-${count.index}" # user-1, user-2`

OR you could use it as an index (position) for pre-defined list
Example: `user = var.user_names[count.index]`

### Referencing array of resources created using count
Format: `provider_type.name[index].attribute`

Example: `aws_iam_user.example[0].arn`

### Limitations of `count`
+ Can't use `count` to loop over inline blocks.
+ The way it handles changes is not suitable. Example if you delete an element in a list, the position of the resources are changed. Hence, resources after the list would be destroyed and recreated again.

## For Each
+ Using `for_each` allows us to have a map of resources that can be references using key/value. This is much better compared to using `count` which references resources based on position, that might change if any element is removed.
+ With `for_each` we can dynamically create inline configuration blocks.

### Referencing resources created using for_each
Example: `aws_iam_user.example["key/name"].<attribute>

### Convert a list to a set
Lists are not supported by `for_each`. So using the `toset(list_variable)` function converts it to a set.

## Conditional Expressions
### Using `count` as a conditional expression
Terraform supports conditional expressions of the format `condition ? true_value : false value`. So we can have a variable of `bool` type and make 1 copy of a resource or not.

Example: `count = var.create_this_resource ? 1 : 0`

For an If-Else statement, the `count` values are reversed based on the conditional expression. You would have 2 resources defined separately.

Example: 
```
# If statement
count = var.create_this_resource ? 1 : 0

# Else statement
count = var.create_this_resource ? 1 : 0
```
### Using `for_each` and `for` for conditional expressions
Example:
```
dynamic "tag" {
    for_each = {
        for key, value in var.custom_tags:
        key => upper(value)
        if key != "Name
    }

    content {
        key = tag.key
        value = tag. value
        propagate_at_launch = true
    }
}
```

### Using `if` String Directive
General format:

`%{ if <condition> }<true_value>%{ endif }`

or

`%{ if <condition> }<true_value>%{ else }<false_value>%{ endif }`

### Interesting Functions
+ Extracting character from a string. 
Example: Extracts first letter from a string value `format("%.1s, var.instance_type)`. If the string was "t2.micro" it would return "t".

### Limitations
+ Cannot reference computed resource outputs in `count` and `for_each`. The values must be known before hand.
+ Cannot use `count` and `for_each` within a module configuration.

## Zero-Downtime Deployments
+ Ensure that you make use of `create_before_destory` for critical resources that could be replaced by deleting and recreating.
+ Change of resource parameters might cause a replacement of resource. Always check the documentation.
+ Check for such actions using `terraform plan`.

### Notes of Refactoring
Making changes to the code, even if the output is the same has gotchas.

+ Changing identifiers results in replacement (which might not be desired). This can be approached in a few ways:
    + Create new resources `apply`. Make changes and then `apply` once again to avoid any replacement.
    + Manually updating state file, but ONLY use `terraform state <original_ref> <new_ref>` command. Change in code and run `terraform plan` to confirm if you did it right.
