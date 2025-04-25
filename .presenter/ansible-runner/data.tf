# Import Current User Credentials
data "azurerm_client_config" "current" {
  provider = azurerm
}

# Import Existing Resource Group created using the Azure CLI
data "azurerm_resource_group" "rg" {
  name = "rg_${var.initials}${var.random_string}"
}

# Import Existing Virtual Network using App Deployment
data "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.initials}${var.random_string}"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Import Existing Subnet using App Deployment
data "azurerm_subnet" "subnet" {
  name                 = "AppSubnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

# Import Existing Network Security Group using App Deployment
data "azurerm_network_security_group" "nsg" {
  name                = "AppSubnetNSG"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Import Existing Existing Load Balancer
data "azurerm_lb" "lb" {
  name                = "lb-${var.initials}${var.random_string}"
  resource_group_name = data.azurerm_resource_group.rg.name
}