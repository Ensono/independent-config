
locals {

  # Each region must have corresponding a shortend name for resource naming purposes
  location_name_map = {
    northeurope   = "eun"
    westeurope    = "euw"
    uksouth       = "uks"
    ukwest        = "ukw"
    eastus        = "use"
    eastus2       = "use2"
    westus        = "usw"
    eastasia      = "ase"
    southeastasia = "asse"
  }

  # Set default values for the resources, if the appropriate variables are not set
  rg_name = var.resource_group_name == "" ? module.default_name.id : var.resource_group_name
  db_server_name = var.database_name == "" ? module.default_name.id : var.database_name
  db_name = var.database_name == "" ? module.default_name.id : var.database_name

}
