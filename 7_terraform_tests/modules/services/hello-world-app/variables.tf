variable "environment" {
    description = "The name of the environment we're deploying to (eg: stage, prod)"
    type = string
}

variable "db_remote_state_bucket" {
    description = "The name of the S3 bucket for database remote state"
    type = string
}

variable "db_remote_state_key" {
    description = "The path for the database remote state key"
    type = string
}

variable "db_use_default_settings" {
    description = "Enable to use default database address and port (localhost and 3306)"
    type = bool
    default = false
}

variable "instance_type" {
  description = "The type of EC2 instance to run"
  type = string
}

variable "min_size" {
  description = "The min number of EC2 instances in the ASG"
  type = number
}

variable "max_size" {
  description = "The max number of EC2 instances in the ASG"
  type = number
}

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type = bool
  default = false
}

variable "custom_tags" {
    description = "Custom tags to apply to the configuration"
    type = map(string)
    default = {}
}

variable "server_text" {
    description = "The text to display on the webpage"
    type = string
    default = "Hello World Default"
}

variable "server_port" {
    description = "The port that the service is running on"
    type = number
    default = 8080
}