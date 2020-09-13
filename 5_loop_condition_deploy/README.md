# Loops
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

### Convert a list to a set
Lists are not supported by `for_each`. So using the `toset(list_variable)` function converts it to a set.