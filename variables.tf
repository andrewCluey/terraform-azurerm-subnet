###########################
# Required Input Parameters
###########################

variable "subnet_name" {
  type        = string
  description = "The name to assign to the Subnet."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group where the new vNet will be created."
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
}

variable "subnet_cidr_list" {
  description = "The address prefix list to use for the subnet"
  type        = list(string)
}


###########################
# Optional Input Parameters
###########################
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
  description = "Enable or Disable network policies for the private link endpoint on the subnet. "
  type        = bool
  default     = true
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
