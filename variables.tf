# variables
variable "name_prefix" {
  type        = string
  description = "The name prefix to use for the vNet. Must be set if 'subnet_name' not set."
  default     = ""
}

variable "subnet_name" {
  type        = string
  description = "The name to assign to the Subnet. Use if the subnet needs a fixed name (such as AzureFirewall or Bastion)."
  default     = ""
}

variable "location" {
  type        = string
  description = "The Azure region where the vNet will be created"
}

variable "location_short" {
  type        = string
  description = "An abbreviation to use for the location. Must be less than 4 characters."
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{1,4}$", var.location_short))
    error_message = "Sorry, but the short location abbreviation should be without spaces and less than 4 characters."
  }
}

variable "environment" {
  type        = string
  description = "The staging environment where the new vNet will be deployed. For example 'Dev'"
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{1,6}$", var.environment))
    error_message = "The environment name should be without spaces and less than 5 characters."
  }
}

variable "project_code" {
  type        = string
  description = "The code assigned to the project"
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{1,8}$", var.project_code))
    error_message = "The project code should be without spaces and less than 8 characters."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group where the new vNet will be created."
  default     = "type"
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
}

variable "subnet_cidr_list" {
  description = "The address prefix list to use for the subnet"
  type        = list(string)
}

variable "route_table_name" {
  description = "The Route Table name to associate with the subnet"
  type        = string
  default     = null
}

variable "route_table_rg" {
  description = "The Route Table RG to associate with the subnet. Default is the same RG as the subnet."
  type        = string
  default     = null
}

variable "network_security_group_name" {
  description = "The Network Security Group name to associate with the subnets"
  type        = string
  default     = null
}

variable "network_security_group_rg" {
  description = "The Network Security Group RG to associate with the subnet. Default is the same RG than the subnet."
  type        = string
  default     = null
}

variable "service_endpoints" {
  description = "The list of Service endpoints to associate with the subnet"
  type        = list(string)
  default     = []
}

variable "enforce_private_link" {
  description = "Enable or Disable network policies for the private link endpoint on the subnet"
  type        = bool
  default     = false
}

variable "subnet_delegation" {
  description = <<EOD
Configuration delegations on subnet
object({
  name = object({
    name = string,
    actions = list(string)
  })
})
EOD
  type        = map(list(any))
  default     = {}
}

variable "tags" {
  description = "tags to apply to the new resources"
  type        = map(string)
  default     = null
}
