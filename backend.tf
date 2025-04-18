terraform {
  backend "azurerm" {
    storage_account_name = "damacostoragestate"
    container_name = "states"
    key = "estados.tfstate"
  }
}