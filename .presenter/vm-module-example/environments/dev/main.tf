# Example usage of the azure-windows-vm module
# This shows how to call the module from your Terraform configuration

module "example_vm" {
  source = "../../modules/azure-windows-vm"

  # VM Configuration
  vm_name             = "myvm01"
  vm_size             = "Standard_D4s_v5"
  resource_group_name = "my-vm-rg"
  location            = "eastus"

  # Network Configuration (existing VNet/subnet)
  existing_vnet_name       = "my-vnet"
  vnet_resource_group_name = "my-networking-rg"
  existing_subnet_name     = "my-subnet"

  # Authentication
  admin_username = "azureadmin"
  admin_password = "YourSecurePassword123!"  # Use Key Vault in production!

  # OS Configuration
  os_sku = "2025-datacenter"

  # Data Disk
  data_disk_size_gb = 256

  # Tags
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# 🎓 Teaching Point: Module Usage
# - source points to the module directory
# - All required variables must be provided
# - Optional variables can use defaults or be overridden
# - Module outputs can be accessed via module.example_vm.vm_id, etc.
