
# Set the name of the resource group
variable "resource_group_name" {
  description = "The name of the resource group to deploy the resources into"
  type        = string
  default     = "independent-config"
}

# Set the location
variable "location" {
  description = "The location to deploy the resources into"
  type        = string
  default     = "westeurope"
}

# Set the database name, if not set then a random name will be chosen
variable "database_name" {
  description = "The name of the postgres database to create"
  type        = string
  default     = ""
}

# Set the name of the admin user for the server
variable "database_server_admin_username" {
  description = "The name of the admin user for the postgres server"
  type        = string
  default     = "pgoverlord"
}
