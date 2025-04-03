

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${var.resource_group_name}"
}



resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = var.aksname
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.aksname}-dns"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2s_v3"
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
    #load_balancer_sku = "standard"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_A2_v2" 
  node_count            = 1
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
  token                  = azurerm_kubernetes_cluster.k8s.kube_config.0.access_token
}

resource "kubernetes_storage_class" "azurefile" {
  metadata {
    name = var.resource_storage_file_name
  }

  storage_provisioner = "file.csi.azure.com"
  reclaim_policy     = "Delete"  # Or "Retain" if you want to keep storage after PVC deletion
  volume_binding_mode = "Immediate"

  parameters = {
    skuName = "Standard_LRS"  # Options: Standard_LRS, Standard_GRS, Standard_ZRS, Premium_LRS
  }

  depends_on = [azurerm_kubernetes_cluster.k8s, azurerm_kubernetes_cluster_node_pool.userpool]
}