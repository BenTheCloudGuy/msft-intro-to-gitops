terraform {
   required_providers {
     azurerm = {
       source  = "hashicorp/azurerm"
       version = "~> 4.0"
     }
   }
}
 
# Configure the Microsoft Azure Provider
provider "azurerm" {
   features {}
   subscription_id = "7fd2bb1c-86be-45c1-a78a-3c84ff31ed4f"
}
 
# Create a new resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags = var.tags
}
 
# Reference an existing virtual network
data "azurerm_virtual_network" "existing_vnet" {
  name                = var.existing_vnet_name
  resource_group_name = var.vnet_resource_group_name # Specify the resource group where the VNet exists
}
 
# Reference an existing subnet
data "azurerm_subnet" "existing_subnet" {
  name                 = var.existing_subnet_name
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = var.vnet_resource_group_name # Same resource group as VNet
}
 
# Create a network interface without public IP
resource "azurerm_network_interface" "nic" {
  name                          = "${var.vm_name}-nic"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  accelerated_networking_enabled = true # Enable accelerated networking
 
  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
 
# Create the Windows virtual machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = var.vm_name
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_D4s_v5" # VM size (adjust as needed)
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  license_type          = "Windows_Server" # Use existing Windows Server license with Software Assurance
  #security_type         = "Standard"       # Set security type to Standard
 
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
 
 
  source_image_reference {
    publisher = "microsoftwindowsserver"
    offer     = "windowsserver"
    sku       = "2025-datacenter" # Adjust SKU as needed (e.g., 2016, 2022)
    version   = "latest"
  }
 
  # Patch orchestration set to Manual updates
  patch_mode = "Manual"
  enable_automatic_updates = false
 
  # Disable boot diagnostics
  boot_diagnostics {
    storage_account_uri = null # Set to null to disable
  }
}
 
resource "azurerm_managed_disk" "adisk" {
  name                 = "${var.vm_name}-disk1"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
}
 
resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.adisk.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "0"
  caching            = "ReadWrite"
}