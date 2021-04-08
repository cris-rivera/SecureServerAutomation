terraform {
  backend "azurerm" {
    resource_group_name  = "imageRG"
    storage_account_name = "tstate20029"
    container_name       = "tfst"
    key                  = "terraform.tfstate"
  }
}

