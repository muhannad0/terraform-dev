variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type = string
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


variable "custom_tags" {
  description = "Custom tags to set on the instances in the ASG"
  type = map(string)
  default = {}
}

variable "server_port" {
  type        = number
  default     = "8080"
  description = "The port the server will use for HTTP requests"
}

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type = bool
}

# variable "enable_new_user_data" {
#   description = "If set to true, configure the new User Data script"
#   type = bool
# }

variable "instance_ami" {
  description = "The AMI to run in the webserver cluster"
  type = string
}

variable "server_text" {
  description = "The text to be displayed on the webserver"
  type = string
}
