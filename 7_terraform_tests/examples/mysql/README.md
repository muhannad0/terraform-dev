# Example: Using MySQL Module

This example explains how to use the MySQL module to deploy a RDS MySQL service.

## Prerequisites
+ Terraform installed (v0.12 and above)
+ AWS credentials already setup

## Configurations
+ Following variables are available for configuration

variable | description
---------|-------------
db_instance_class (required) | the type of instance to be deployed (eg: t2.micro etc)
db_allocated_storage (required) | storage capacity (in GB) of the database
db_identifier_prefix (required) | an indentifier for the database service
db_name (required) | the name of the database to be created
db_admin_username (required) | the administrator username for the database
db_admin_password (required) | the password of the administrator for the database

## Quick-start
+ To deploy run
```
terraform init
terraform apply
```

+ To cleanup after you're done testing
```
terraform destroy
```
