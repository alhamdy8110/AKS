 variable "virtual_network_name_aks" {
   type        = string
   description = "Virtual network name."
   default     = "aks-vnet"
 }

 variable "aks_subnet_name" {
   type        = string
   description = "Name of the subset."
   default     = "aks-subnet"
 }

variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string
  default     = "rg-aks"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}
variable "aksname" {
  type = string
  default = "aks-cluster"
}

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 1
}

variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."
  default     = null
}

variable "username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "azureadmin"
}

variable "resource_storage_file_name" {
  type        = string
  default     = "azurefileaks"
  description = "Prefix of the storga file name ."
}

variable "acrname" {
  type = string
  default = "acraksclusternginx"
}

variable "dns_zone_name" {
  type        = string
  default     = "elpatrontitan.com"
  description = "Name of the DNS zone."
  sensitive = true
}

 variable "appgw_subnet_name" {
   type        = string
   description = "Name of the subset."
   default     = "appgw-subnet"
 }

 variable "app_gateway_name" {
   description = "Name of the Application Gateway"
   type        = string
   default     = "agic-appgw"
 }


output "app_gateway_id" {
   description = "The ID of the Azure Application Gateway"
   value       = azurerm_application_gateway.appgw.id
 }
 
 output "agic_identity_client_id" {
   description = "The Client ID of the AGIC User Assigned Managed Identity"
   value       = azurerm_user_assigned_identity.agic_identity.client_id
 }

  variable "app_gateway_tier" {
   description = "Tier of the Application Gateway tier."
   type        = string
   default     = "Standard_Small"
 }