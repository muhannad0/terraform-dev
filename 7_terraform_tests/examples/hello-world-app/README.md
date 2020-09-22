# Example: Using Hello World App Module

This example explains how to use the Hello World App module to deploy the Hello World service.

## Prerequisites
+ Terraform installed (v0.12 and above)
+ AWS credentials already setup

## Configurations
+ Following variables are available for configuration

variable | description
---------|-------------
environment (required) | the name of the deploy environment (eg: dev, stage, prod)
db_remote_state_bucket (required) | the subnet ids to deploy the cluster to
db_remote_state_key (required) | the ami id for the instance to be deployed
instance_type (required) | the type of instance to be deployed (eg: t2.micro etc)
min_size (required) | the minimum number of instances that must be running in the cluster
max_size (required) | the maximum number of instances that must be running in the cluster
enable_autoscaling | enables autoscaling the number of instances based on the schedule (business hours and non-business hours) (default: false)
db_use_default_settings | enable to use default settings for database address and port (localhost, default port) (default: false)
custom_tags | add custom tags to the instances deployed in the cluster (default: empty)
server_text | set the default title text on the main webpage of the service

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
