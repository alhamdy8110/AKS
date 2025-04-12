output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

 output "application_gateway_name" {
   value = azurerm_application_gateway.appgw.name
 }

 output "identity_name" {
   value = azurerm_user_assigned_identity.aks.name
 }

 output "identity_resource_id" {
   value = azurerm_user_assigned_identity.aks.id
 }

 output "identity_client_id" {
   value = azurerm_user_assigned_identity.aks.client_id
 }

  output "application_ip_address" {
   value = azurerm_public_ip.appgw_public_ip.ip_address
 }
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].username
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "azurerm_container_registry" {
  value = azurerm_container_registry.acr_name
  sensitive = true
}

output "dns_zone_name" {
  value = azurerm_dns_zone.dns-zone.name
  sensitive = true
}