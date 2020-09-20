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

variable "db_admin_username" {
    description = "The admin username for the database"
    type = string
}

variable "db_admin_password" {
    description = "The password for the admin user for the database"
    type = string
}