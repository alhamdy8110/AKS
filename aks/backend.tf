terraform {
    backend "azurerm" {
      resource_group_name  = "rg-aks"
      storage_account_name = "akstfstategithubaction"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }
}