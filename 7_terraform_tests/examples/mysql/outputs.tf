output "db_address" {
    value = module.mysql.address
    description = "The address of the database"
}

output "db_port" {
    value = module.mysql.port
    description = "The port that the database service is running on"
}