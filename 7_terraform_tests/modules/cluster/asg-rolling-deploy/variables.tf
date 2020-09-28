variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "instance_ami" {
  description = "The AMI to run in the webserver cluster"
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

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type = bool
  default = false
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

variable "subnet_ids" {
    description = "The subnet IDs to deploy to"
    type = list(string)
}

variable "target_group_arns" {
    description = "THe ARNs of ELB target groups to register instances"
    type = list(string)
    default = []
}

variable "health_check_type" {
    description = "The type of health check to perform. Must be on of EC2, ELB"
    type = string
    default = "EC2"
}

variable "user_data" {
    description = "The User Data script to run on instance startup"
    type = string
    default = null
}