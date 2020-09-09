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

variable "server_port" {
  type        = number
  default     = "8080"
  description = "The port the server will use for HTTP requests"
}
