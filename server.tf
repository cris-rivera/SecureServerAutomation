provider "azurerm" {
  features {}
}

#resource "azurerm_resource_group" "crisResourceGroup" {
  #name      = "cris-resources"
  #location  = "westus"
#}

resource "azurerm_virtual_network" "crisVNet" {
  name                = "cris-network"
  address_space       = ["10.0.0.0/16"]
  location            = "westus"
  resource_group_name = "imageRG"  

  #location            = azurerm_resource_group.crisResourceGroup.location
  #resource_group_name = azurerm_resource_group.crisResourceGroup.name
}

resource "azurerm_subnet" "crisSubNet" {
  name                 = "crisNet"
  #resource_group_name  = azurerm_resource_group.crisResourceGroup.name
  resource_group_name  = "imageRG"
  virtual_network_name = azurerm_virtual_network.crisVNet.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_public_ip" "CrisPublicIP" {
  name                = "CrisPublicIp"
  #resource_group_name = azurerm_resource_group.crisResourceGroup.name
  #location            = azurerm_resource_group.crisResourceGroup.location
  resource_group_name  = "imageRG"
  location            = "westus"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "cris_nic" {
  name                  = "cris_nic"
  #location              = azurerm_resource_group.crisResourceGroup.location
  #resource_group_name   = azurerm_resource_group.crisResourceGroup.name
  location            = "westus"
  resource_group_name  = "imageRG"

  ip_configuration {

    name                          = "internal"
    subnet_id                     = azurerm_subnet.crisSubNet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.CrisPublicIP.id
  }
}

resource "azurerm_windows_virtual_machine" "crisWindowsServer" {
  name                  = "crisVM"
  #resource_group_name   = azurerm_resource_group.crisResourceGroup.name
  #location              = azurerm_resource_group.crisResourceGroup.location
  resource_group_name  = "imageRG"
  location            = "westus"
  size                  = "Standard_F2"
  #admin_username        = "testadmin"
  #admin_password        = "cyberOps@UofA"
  
  admin_username = var.localUsr
  admin_password = var.localPwd

  network_interface_ids  = [
    azurerm_network_interface.cris_nic.id,
  ]

  os_disk {
    caching               = "ReadWrite"
    storage_account_type  = "Standard_LRS"
  }

  source_image_id = "/subscriptions/316098cb-8835-448e-90e6-20a073644853/resourceGroups/imageRG/providers/Microsoft.Compute/images/finalSTIGImg"
  
  provision_vm_agent = true

  #source_image_reference {
    #publisher   = "MicrosoftWindowsServer"
    #offer       = "WindowsServer"
    #sku         = "2016-Datacenter"
    #version     = "latest"
  #}

}
