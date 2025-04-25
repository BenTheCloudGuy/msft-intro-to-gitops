## Import Core Modules   
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"
}

module "regions" {
  source                    = "Azure/avm-utl-regions/azurerm"
  version                   = "0.3.0"
  enable_telemetry          = true
  availability_zones_filter = true
}

module "vm_sku" {
  source        = "Azure/avm-utl-sku-finder/azapi"
  version       = "0.3.0"
  location      = data.azurerm_resource_group.rg.location
  cache_results = false
  vm_filters = {
    max_vcpus = 2

  }
}

# Create Azure Public IP for LoadBalancer
resource "azurerm_public_ip" "runnerpip" {
  name                = "runnerpip${var.initials}${var.random_string}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = local.resourceTags
}


# Create Github Runner VM with System Assigned Identity
module "ghrunner" {
  source                             = "Azure/avm-res-compute-virtualmachine/azurerm"
  version                            = "~>0.17.0"
  enable_telemetry                   = true
  count                              = var.appServersConfig.vmcount
  resource_group_name                = data.azurerm_resource_group.rg.name
  name                               = "ghrunner${count.index}" # Unique name per instance
  location                           = data.azurerm_resource_group.rg.location
  encryption_at_host_enabled         = false
  generate_admin_password_or_ssh_key = false
  os_type                            = "Linux"
  sku_size                           = var.appServersConfig.vm_sku
  zone                               = var.appServersConfig.zones[0]
  tags                               = local.resourceTags
  admin_username                     = var.appServersConfig.adminUsername
  admin_ssh_keys = [
    {
      public_key = file(var.appServersConfig.key_path)
      username   = var.appServersConfig.adminUsername
    }
  ]
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  managed_identities = {
    system_assigned = true
  }
  network_interfaces = {
    nic0 = {
      name = "ghrunner${count.index}-nic0"
      ip_configurations = {
        ipconfig0 = {
          name                          = "ipconfig1"
          private_ip_address_allocation = "Dynamic"
          private_ip_subnet_resource_id = data.azurerm_subnet.subnet.id
          public_ip_address_resource_id = azurerm_public_ip.runnerpip.id
        }
      }
    }
  }
}

# Assign RBAC Roles to the VM System Assigned Identity
resource "azurerm_role_assignment" "ghrunner_contributor" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = module.ghrunner[0].system_assigned_mi_principal_id
}

resource "azurerm_role_assignment" "ghrunner_storage" {

  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.ghrunner[0].system_assigned_mi_principal_id
}
