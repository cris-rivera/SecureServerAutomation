provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "crisResourceGroup" {
  name      = "cris-resources"
  location  = "westus"
}

resource "azurerm_virtual_network" "crisVNet" {
  name                = "cris-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.crisResourceGroup.location
  resource_group_name = azurerm_resource_group.crisResourceGroup.name
}

resource "azurerm_subnet" "crisSubNet" {
  name                 = "crisNet"
  resource_group_name  = azurerm_resource_group.crisResourceGroup.name
  virtual_network_name = azurerm_virtual_network.crisVNet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "cris_nic" {
  name                  = "cris_nic"
  location              = azurerm_resource_group.crisResourceGroup.location
  resource_group_name   = azurerm_resource_group.crisResourceGroup.name

  ip_configuration {

    name                          = "internal"
    subnet_id                     = azurerm_subnet.crisSubNet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "crisWindowsServer" {
  name                  = "crisVM"
  resource_group_name   = azurerm_resource_group.crisResourceGroup.name
  location              = azurerm_resource_group.crisResourceGroup.location
  size                  = "Standard_F2"
  admin_username        = "testadmin"
  admin_password        = "cyberOps@UofA"
  network_interface_ids  = [
    azurerm_network_interface.cris_nic.id,
  ]

  os_disk {
    caching               = "ReadWrite"
    storage_account_type  = "Standard_LRS"
  }

  source_image_reference {
    publisher   = "MicrosoftWindowsServer"
    offer       = "WindowsServer"
    sku         = "2016-Datacenter"
    version     = "latest"
  }

}
