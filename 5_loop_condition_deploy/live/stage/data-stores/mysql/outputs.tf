output "address" {
    value = module.mysql_database.address
    description = "The DNS address of the database"
}

output "port" {
    value = module.mysql_database.port
    description = "The port that the database service is running on"
}