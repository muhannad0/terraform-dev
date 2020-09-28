variable "alb_name" {
    description = "The name for this ALB"
    type = string
}

variable "subnet_ids" {
    description = "The subnet IDs to deploy the load balancer to"
    type = list(string)
}