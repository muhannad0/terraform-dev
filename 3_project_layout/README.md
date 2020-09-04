# Using File Layouts to Isolate State

Terraform projects can be stored on separate folders for each environment (dev, stage, prod) with separate backend.

## Folder Structure
```
Environment
    |_ Components
    |_ Services
        |_ Apps
    |_ Storage
        |_ Database
        |_ File/object Storage
```

## File Naming Conventions
Generally you would have:

+ `variables.tf` for input variables
+ `outputs.tf` for output variables
+ `main.tf` for resources
    + `main.tf` can be broken down based on functionality (like `iam.tf`, `s3.tf`, `database.tf`)


## CLI References
### Creating a Secret for DB Credentials
```
aws secretsmanager create-secret --name mysql-master-password-stage --description "terraform-db-master-pass-stage" --secret-string Sup3rS3cr3tP4s5
```