variable "db_identifier_prefix" {
    description = "The database instance indentifier prefix"
    type = string
}

variable "db_instance_class" {
    description = "The instance class of the database (eg: db.t2.micro)"
    type = string
}

variable "db_allocated_storage" {
    description = "The amount of storage allocated to the datbase in GB"
    type = number
}

variable "db_name" {
    description = "The name of the database"
    type = string
}

variable "db_master_username" {
    description = "The master username for the database"
    type = string
}

variable "db_master_password_secret_id" {
    description = "The name of the secret corresponding to the database master user password stored in Secrets Manager"
    type = string
}