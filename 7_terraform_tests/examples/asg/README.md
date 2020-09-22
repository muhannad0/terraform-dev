# Example: Using Auto Scaling Group Module

This example explains how to use the Auto Scaling Group (asg-rolling-deploy) module to deploy a cluster of web server instances.

## Prerequisites
+ Terraform installed (v0.12 and above)
+ AWS credentials already setup

## Configurations
+ Following variables are available for configuration

variable | description
---------|-------------
cluster_name (required) | set a name for the cluster resources
subnet_ids (required) | the subnet ids to deploy the cluster to
instance_ami (required) | the ami id for the instance to be deployed
instance_type (required) | the type of instance to be deployed (eg: t2.micro etc)
min_size (required) | the minimum number of instances that must be running in the cluster
max_size (required) | the maximum number of instances that must be running in the cluster
enable_autoscaling | enables autoscaling the number of instances based on the schedule (business hours and non-business hours) (default: false)
custom_tags | add custom tags to the instances deployed in the cluster (default: empty)
server_port | set the port to listen for HTTP requests on the instances (default: 8080)
target_group_arns | the load balancer target group ARN to register the instances (default: empty)
health_check_type  | the health check type to determine if the launched instances is ready to accept requests (default: EC2)

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
