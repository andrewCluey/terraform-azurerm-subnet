######### terraform-azurerm-subnet ############
#
# Creates a Subnet in an existing vNet.
# Options to associate with an existing Route Table and NSG
#
################################################
# Minimum azure provider to use
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.54.0"
    }
  }
}

locals {
  # Use the subnets RG if Route Table resource group has not been specified
  route_table_rg = coalesce(var.route_table_rg, var.resource_group_name)

  # Use the subnets RG if NSG Resource Group has not been specified.
  network_security_group_rg = coalesce(var.network_security_group_rg, var.resource_group_name)
}

# Lookup route table to associate with the subnet IF route table name is specified
data "azurerm_route_table" "route_table" {
  count               = var.route_table_name == null ? 0 : 1
  name                = var.route_table_name
  resource_group_name = local.route_table_rg
}

# Lookup NSG to associate with the subnet IF NSG name is specified
data "azurerm_network_security_group" "nsg_data" {
  count               = var.network_security_group_name == null ? 0 : 1
  name                = var.network_security_group_name
  resource_group_name = local.network_security_group_rg
}


# Create the subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.subnet_cidr_list

  service_endpoints = var.service_endpoints

  dynamic "delegation" {
    for_each = var.subnet_delegation
    content {
      name = delegation.key
      dynamic "service_delegation" {
        for_each = toset(delegation.value)
        content {
          name    = service_delegation.value.name
          actions = service_delegation.value.actions
        }
      }
    }
  }

  enforce_private_link_endpoint_network_policies = var.enforce_private_link
}


# Associate the NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "subnet_association" {
  count = var.network_security_group_name == null ? 0 : 1

  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = data.azurerm_network_security_group.nsg_data[0].id
}

# Associate the route table with the subnet
resource "azurerm_subnet_route_table_association" "route_table_association" {
  count = var.route_table_name == null ? 0 : 1

  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = data.azurerm_route_table.route_table[0].id
}
