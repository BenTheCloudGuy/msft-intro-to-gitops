# 🎓 Teaching Point: Terraform Module Structure
# This file contains the core resource definitions for the Windows VM module.
# This module creates exactly what the original vm.tf created:
# - Resource Group
# - Network Interface (with reference to existing VNet/subnet)
# - Windows Virtual Machine
# - Managed Disk
# - Disk Attachment

# ═══════════════════════════════════════════════════════════════════════════════
# DATA SOURCES - Query Existing Infrastructure
# ═══════════════════════════════════════════════════════════════════════════════
# 🎓 Teaching Point: Data Sources
# The original vm.tf queried existing VNet and subnet, so this module does too.
# This matches the pattern from the original file.

data "azurerm_virtual_network" "existing_vnet" {
  name                = var.existing_vnet_name
  resource_group_name = var.vnet_resource_group_name
}

data "azurerm_subnet" "existing_subnet" {
  name                 = var.existing_subnet_name
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = var.vnet_resource_group_name
}

# ═══════════════════════════════════════════════════════════════════════════════
# RESOURCE GROUP
# ═══════════════════════════════════════════════════════════════════════════════

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# 🎓 Teaching Point: Resource Groups
# - Logical container for Azure resources
# - All resources in this module will be created in this RG
# - Makes cleanup easy (delete RG = delete all resources)
# - Enables RBAC at RG level

# ═══════════════════════════════════════════════════════════════════════════════
# NETWORK INTERFACE
# ═══════════════════════════════════════════════════════════════════════════════

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

# 🎓 Teaching Point: Accelerated Networking
# - Provides up to 30 Gbps networking throughput (vs 1-2 Gbps without)
# - FREE - no additional cost
# - Supported on most D, E, F, H, and M series VMs
# - Industry best practice: ALWAYS enable on production VMs
# - Only downside: Can't be enabled on older/smaller VM sizes

# 🎓 Teaching Point: Why Separate NIC Resource?
# - Could use inline network_interface block in VM resource
# - Separate NIC allows:
#   * Independent NIC management (swap NICs without recreating VM)
#   * Multiple NICs per VM
#   * NIC-level NSG attachment
#   * Clearer resource dependencies
# - Best practice for production environments

# ═══════════════════════════════════════════════════════════════════════════════
# WINDOWS VIRTUAL MACHINE
# ═══════════════════════════════════════════════════════════════════════════════

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = var.vm_name
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  license_type          = "Windows_Server" # Use existing Windows Server license with Software Assurance

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.os_sku
    version   = "latest"
  }

  # Patch orchestration set to Manual updates
  patch_mode                = "Manual"
  enable_automatic_updates  = false

  # Disable boot diagnostics
  boot_diagnostics {
    storage_account_uri = null # Set to null to disable
  }
}

# 🎓 Teaching Point: OS Disk Storage Type
# - Premium_LRS (default in this module):
#   * Required for 99.9% SLA
#   * 500+ IOPS, 60+ MB/s throughput
#   * ~$20/month for 128GB
#   * Production standard
# - Standard_LRS:
#   * Only 99.5% SLA
#   * 120 IOPS, 25 MB/s throughput
#   * ~$15/month for 128GB
#   * Only for non-critical dev/test
# - Verdict: Premium_LRS is worth the extra $5/month!

# 🎓 Teaching Point: Patch Management
# - Manual (default in this module):
#   * Enterprise standard - controlled maintenance windows
#   * Test patches in dev before prod
#   * Aligns with ITIL/change management
# - AutomaticByPlatform:
#   * Azure manages patching automatically
#   * Good for dev/test, risky for production
#   * Can cause unexpected reboots
# - Recommendation: Manual for prod, AutomaticByPlatform for dev

# 🎓 Teaching Point: Boot Diagnostics
# - Disabled by default (costs money - requires storage account)
# - Enable when troubleshooting boot issues
# - Shows serial console output and screenshots
# - Cost: ~$1-2/month per VM
# - Best practice: Enable for production VMs, disable for dev/test to save costs

# 🎓 Teaching Point: License Type
# - "Windows_Server" = Azure Hybrid Benefit (AHUB)
# - Requires existing Windows Server license with Software Assurance
# - Saves ~40% on compute costs (only pay for base compute, not Windows license)
# - null = Pay for Windows license included in VM cost
# - Recommendation: Use AHUB if you have licenses, significant savings!

# ═══════════════════════════════════════════════════════════════════════════════
# MANAGED DISK (DATA DISK)
# ═══════════════════════════════════════════════════════════════════════════════

resource "azurerm_managed_disk" "adisk" {
  name                 = "${var.vm_name}-disk1"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
}

# 🎓 Teaching Point: Separate Data Disks
# - Why separate OS and data disks?
#   * Different performance requirements (OS = low IOPS, data = high IOPS)
#   * Different backup schedules (OS = weekly, data = daily)
#   * Easier to resize data disk independently
#   * Can detach/attach to different VMs
#   * Best practice for SQL Server (separate disks for data/logs/tempdb)
# - When to use:
#   * Databases (SQL Server, PostgreSQL, etc.)
#   * File servers
#   * Applications with high I/O requirements
# - When NOT needed:
#   * Simple web servers
#   * Jump boxes / bastion hosts
#   * Development VMs

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.adisk.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = 0
  caching            = "ReadWrite"
}

# 🎓 Teaching Point: LUN (Logical Unit Number)
# - Identifies the disk to the OS (like drive letter, but lower level)
# - LUN 0-63 supported on Azure
# - Start at 0, increment for additional disks
# - Important for SQL Server (specific LUNs for data/logs)
