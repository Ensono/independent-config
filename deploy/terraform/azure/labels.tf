# This template used the Terraform Null Label resource to consistently name
# resources that are deployed for this independent config system.
#
# By using this the minimal amount of configuration is required, e.g. the resources
# need to be explicitly named
#
# This is not used for things that need to have specific name, such as DNS zones

module "default_name" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.25.0"
  namespace  = var.company_name
  name       = lookup(local.location_name_map, var.location, "westeurope")
  attributes = var.attributes
  delimiter  = "-"
  tags       = var.tags
}