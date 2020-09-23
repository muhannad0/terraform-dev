variable "environment" {
    description = "The deploy environment (eg: stage, prod)"
    type = string
    default = "example"
}

variable "mysql_config" {
    description = "The configuration for the MySQL database"
    type = object({
        address = string
        port = number
    })

    default = {
        address = "mock.localhost"
        port = 1234
    }
}

variable "server_text" {
    description = "The text to display on the the main webpage"
    type = string
    default = "Hello World Example"
}