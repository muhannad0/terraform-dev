variable "db_remote_state_bucket" {
    description = "The name of the S3 bucket for database remote state"
    type = string
}

variable "db_remote_state_key" {
    description = "The path for the database remote state key"
    type = string
}

variable "environment" {
    description = "The deploy environment (eg: stage, prod)"
    type = string
}

variable "server_text" {
    description = "The text the web server should display"
    type = string
    default = "Hello World Stage"
}