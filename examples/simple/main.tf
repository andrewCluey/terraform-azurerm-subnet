provider "azurerm" {
  features {}
}

locals {
  project_code = "ps1234"
  #subnet_name = var.name_prefix != "" ? lower("sn-${var.name_prefix}-${var.project_code}-${var.location_short}-${var.environment}") : var.subnet_name
  subnet_name_prefix = lower("sn-${local.project_code}-${var.environment}")

  module_tag = {
    "module" = basename(abspath(path.module))
  }

  default_tags = {
    environment = "dev"
    project     = local.project_code
  }

  tags = merge(local.module_tag, local.default_tags)

}


# Create a new Resource Group
resource "azurerm_resource_group" "project_group" {
  name     = "rg-subnet-test"
  location = "UK South"
}


# Create a new vNet
module "vnet_simple" {
  source = "andrewCluey/vnet/azurerm"

  project_code        = local.project_code
  environment         = "dev"
  location            = "UK South"
  location_short      = var.location_short
  resource_group_name = azurerm_resource_group.project_group.name
  vnet_cidr           = ["10.0.0.0/22"]
  dns_servers         = ["10.20.0.50", "10.20.0.51"] # Not required if using Azure provided DNS.
  tags                = local.tags
}

# Create subnets to add to the new vNet
module "simple_subnet" {
  source  = "andrewCluey/subnet/azurerm"
  version = "0.6.1"

  subnet_name          = "${local.subnet_name_prefix}-default"
  resource_group_name  = azurerm_resource_group.project_group.name
  vnet_name            = module.vnet_simple.vnet_name
  subnet_cidr_list     = ["10.0.0.0/24"]
  enforce_private_link = true

}
