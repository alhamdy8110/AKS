#https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform?pivots=development-environment-azure-cli

 # Locals block for hardcoded names
  resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${var.resource_group_name}"
}
 
 locals {
   backend_address_pool_name      = "${azurerm_virtual_network.aks_vnet.name}-beap"
   frontend_port_name             = "${azurerm_virtual_network.aks_vnet.name}-feport"
   frontend_ip_configuration_name = "${azurerm_virtual_network.aks_vnet.name}-feip"
   http_setting_name              = "${azurerm_virtual_network.aks_vnet.name}-be-htst"
   listener_name                  = "${azurerm_virtual_network.aks_vnet.name}-httplstn"
   request_routing_rule_name      = "${azurerm_virtual_network.aks_vnet.name}-rqrt"
 }



resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.virtual_network_name_aks
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.0.0/21"]
}

data "azurerm_subnet" "kubesubnet" {
  name                 = var.aks_subnet_name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}


# User-assigned identity for AKS
resource "azurerm_user_assigned_identity" "aks" {
  name                = "aks-${var.aks_cluster_name}-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

 # aks cluster
 resource "azurerm_kubernetes_cluster" "aks" {
   name                              = var.aks_cluster_name
   location                          = azurerm_resource_group.rg.location
   resource_group_name               = azurerm_resource_group.rg.name
   dns_prefix                        = "${var.aks_cluster_name}-dns"
   private_cluster_enabled           = var.aks_private_cluster
   role_based_access_control_enabled = var.aks_enable_rbac
   sku_tier                          = var.aks_sku_tier

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  default_node_pool {
    name       = "systempool"
    vm_size    = var.aks_vm_size
    node_count = var.node_count
    vnet_subnet_id  = data.azurerm_subnet.kubesubnet.id
  }

  
  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }
  network_profile {
    # network_plugin    = "kubenet"
    network_plugin    = "azure"
    dns_service_ip = var.aks_dns_service_ip
    service_cidr   = var.aks_service_cidr
    #load_balancer_sku = "standard"
  }
    ingress_application_gateway {
    gateway_id = azurerm_application_gateway.appgw.id
  }

  depends_on = [
    azurerm_application_gateway.appgw
  ]
}

resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_A2_v2" 
  node_count            = 1
}

resource "azurerm_container_registry" "acr_name" {
  name                = var.acrname
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}


resource "azurerm_dns_zone" "dns-zone" {
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "appgw_subnet" {
   name                 = var.appgw_subnet_name
   resource_group_name  = azurerm_resource_group.rg.name
   virtual_network_name = azurerm_virtual_network.aks_vnet.name
   address_prefixes     = ["10.0.8.0/24"]
 }

 
 resource "azurerm_public_ip" "appgw_public_ip" {
   name                = "appgw-public-ip"
   location            = azurerm_resource_group.rg.location
   resource_group_name = azurerm_resource_group.rg.name
   allocation_method   = "Static"
   sku                 = "Standard"
   zones               = ["1"] 
 }
 
 resource "azurerm_application_gateway" "appgw" {
   name                = var.app_gateway_name
   location            = azurerm_resource_group.rg.location
   resource_group_name = azurerm_resource_group.rg.name
 
   sku {
     name     = var.app_gateway_tier
     tier     = var.app_gateway_tier
     capacity = 1
   }

   zones = ["1"]
 
   gateway_ip_configuration {
     name      = "gateway-ip-config"
     subnet_id = azurerm_subnet.appgw_subnet.id
   }
 
   frontend_port {
     name =  local.frontend_port_name
     port = 80
   }
 
   frontend_ip_configuration {
     name                 = local.frontend_ip_configuration_name
     public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
   }
 
   backend_address_pool {
     name = local.backend_address_pool_name
   }
 
   backend_http_settings {
     name                  = local.http_setting_name
     cookie_based_affinity = "Disabled"
     port                  = 80
     protocol              = "Http"
     request_timeout       = 1
   }
 
   http_listener {
     name                           = local.listener_name
     frontend_ip_configuration_name = local.frontend_ip_configuration_name
     frontend_port_name             = local.frontend_port_name
     protocol                       = "Http"
   }
 
   request_routing_rule {
     name                       = local.request_routing_rule_name
     priority                   = 1
     rule_type                  = "Basic"
     http_listener_name         = local.listener_name
     backend_address_pool_name  = local.backend_address_pool_name
     backend_http_settings_name = local.http_setting_name
   }

   # Since this sample is creating an Application Gateway 
   # that is later managed by an Ingress Controller, there is no need 
   # to create a backend address pool (BEP). However, the BEP is still 
   # required by the resource. Therefore, "lifecycle:ignore_changes" is 
   # used to prevent TF from managing the gateway.
   lifecycle {
     ignore_changes = [
       tags,
       backend_address_pool,
       backend_http_settings,
       http_listener,
       probe,
       request_routing_rule,
     ]
   }

 }
 
   data "azurerm_user_assigned_identity" "ingress" {
   name                = "ingressapplicationgateway-${azurerm_kubernetes_cluster.aks.name}"
   resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
 }


 resource "azurerm_role_assignment" "agic_rg_reader" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_user_assigned_identity.ingress.principal_id
}
 
 resource "azurerm_role_assignment" "agic_appgw_contributor" {
   scope                = azurerm_application_gateway.appgw.id
   role_definition_name = "Contributor"
   principal_id         = data.azurerm_user_assigned_identity.ingress.principal_id
 }
 
 resource "azurerm_role_assignment" "agic_vnet_reader" {
  scope                = azurerm_virtual_network.aks_vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_user_assigned_identity.ingress.principal_id
 }