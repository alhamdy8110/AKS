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
variable "aks_cluster_name" {
  type = string
  default = "aks-cluster"
}

 variable "aks_private_cluster" {
   type        = bool
   description = "(Optional) Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located."
   default     = false
 }

  variable "aks_enable_rbac" {
   description = "(Optional) Is Role Based Access Control based on Azure AD enabled?"
   type        = bool
   default     = false
 }

 variable "aks_sku_tier" {
   type        = string
   description = "(Optional) The SKU tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA)."
   default     = "Free"
 }

 variable "aks_service_cidr" {
   type        = string
   description = "(Optional) The Network Range used by the Kubernetes service."
   default     = "192.168.0.0/20"
 }

 variable "aks_dns_service_ip" {
   type        = string
   description = "(Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)."
   default     = "192.168.0.10"
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
   default     = "Standard"
 }