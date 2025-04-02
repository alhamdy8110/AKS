# Generate random resource group name
resource "random_string" "rg_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${var.resource_group_name_prefix}-${random_string.rg_suffix.result}"
}

resource "random_string" "aks_cluster_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "aks_dns_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = "aks-${random_string.aks_cluster_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-${random_string.aks_dns_suffix.result}"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.node_count
  }
  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}