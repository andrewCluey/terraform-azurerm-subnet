provider "azurerm" {
  features {}
}

locals {
  project_code = "ps1234"
}

resource "azurerm_resource_group" "project_group" {
  name     = "project_group"
  location = "UK South"
}

module "vnet_simple" {
  source  = "andrewCluey/vnet/azurerm"

  project_code        = local.project_code
  environment         = "dev"
  location            = "UK South"
  location_short      = "uks"
  resource_group_name = azurerm_resource_group.project_group.name
  vnet_cidr           = ["10.0.0.0/22"]
  dns_servers         = ["10.20.0.50", "10.20.0.51"] # Not required if using Azure provided DNS.
}


module "simple_subnet" {
  source  = "andrewCluey/subnet/azurerm"

  environment          = "dev"
  name_prefix          = "strorage"
  project_code         = local.project_code
  location             = "UK South"
  location_short       = "uks"
  resource_group_name  = azurerm_resource_group.project_group.name
  virtual_network_name = module.vnet_simple.vnet_name
  subnet_cidr_list     = ["10.0.0.0/24"]
  subnet_delegation = {
    app-service-plan = [
      {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    ]
  }

  service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Web"]
}
