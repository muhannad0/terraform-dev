output "address" {
    value = module.mysql.address
    description = "The DNS address of the database"
}

output "port" {
    value = module.mysql.port
    description = "The port that the database service is running on"
}