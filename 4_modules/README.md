# Using Modules

By using modules, we can make Terraform configurations more flexible and resuable for various environments.

## Folder Structure
```
global
|_ s3

modules
|_ data-stores
|   |_ mysql
|_ services
    |_ webserver-cluster

prod
|_ data-stores
|   |_ mysql
|_ services
    |_ webserver-cluster

stage
|_ data-stores
|   |_ mysql
|_ services
    |_ webserver-cluster
```

## Modules
### MySQL
Module creates a MySQL database.

### Webserver Cluster
Module creates an Auto Scaling Group of Webservers behind a Load Balancer.

## Environments
Prod and Stage environments makes use of the modules above.