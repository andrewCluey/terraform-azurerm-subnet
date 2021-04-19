locals {
  name_prefix = var.name_prefix != "" ? replace(var.name_prefix, "/[a-z0-9]$/", "$0-") : ""
  subnet_name = lower("${local.name_prefix}-${var.project_code}-${var.location_short}-${var.environment}")
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  default_tags = {
    environment = var.environment
    project     = var.project_code
  }

  tags                      = merge(var.tags, local.module_tag, local.default_tags)
  route_table_rg            = coalesce(var.route_table_rg, var.resource_group_name)
  network_security_group_rg = coalesce(var.network_security_group_rg, var.resource_group_name)
}


data "azurerm_route_table" "route_table" {
  count               = var.route_table_name == null ? 0 : 1
  name                = var.route_table_name
  resource_group_name = local.route_table_rg
}

data "azurerm_network_security_group" "nsg_data" {
  count               = var.network_security_group_name == null ? 0 : 1
  name                = var.network_security_group_name
  resource_group_name = local.network_security_group_rg
}


resource "azurerm_subnet" "subnet" {
  name                 = local.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
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


resource "azurerm_subnet_network_security_group_association" "subnet_association" {
  count = var.network_security_group_name == null ? 0 : 1

  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = data.azurerm_network_security_group.nsg_data[0].id
}

resource "azurerm_subnet_route_table_association" "route_table_association" {
  count = var.route_table_name == null ? 0 : 1

  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = data.azurerm_route_table.route_table[0].id
}