# 🎓 Teaching Point: Module Outputs
# Outputs expose information about created resources.
# Other modules or root configuration can use these values.

# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.rg.id
}

# VM Outputs
output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_windows_virtual_machine.vm.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_windows_virtual_machine.vm.name
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.nic.private_ip_address
}

# Network Interface Outputs
output "nic_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.nic.id
}

# Data Disk Outputs
output "data_disk_id" {
  description = "ID of the data disk"
  value       = azurerm_managed_disk.adisk.id
}

output "data_disk_name" {
  description = "Name of the data disk"
  value       = azurerm_managed_disk.adisk.name
}

# 🎓 Teaching Point: Output Best Practices
# - Expose useful information for module composition
# - Include IDs for resource references
# - Include human-readable names
# - Document what each output provides

#
# 🎓 TEACHING POINT: Outputs expose module information
# - Enable module composition (one module's output → another's input)
# - Provide information to users (IPs, IDs, etc.)
# - Essential for debugging and troubleshooting
# - Document what each output provides

###################
# VM Information
###################

# 🎓 WHY OUTPUT: Resource IDs are needed for dependencies
# - Other resources may need to reference this VM
# - Used for RBAC assignments
# - Required for VM extensions
output "vm_id" {
  description = "The resource ID of the Windows virtual machine. Use this for creating VM extensions or RBAC assignments."
  value       = azurerm_windows_virtual_machine.this.id
}

# 🎓 WHY OUTPUT: Name needed for reference
# - Useful in scripts and automation
# - Display in Terraform output for documentation
output "vm_name" {
  description = "The name of the Windows virtual machine. Useful for automation scripts and documentation."
  value       = azurerm_windows_virtual_machine.this.name
}

# 🎓 WHY OUTPUT: Private IP needed for connectivity
# - Configure DNS records
# - Add to load balancer backends
# - Document in runbooks
# - Configure monitoring
output "vm_private_ip" {
  description = "The private IP address assigned to the VM's network interface. Use for DNS records, load balancers, or monitoring configuration."
  value       = azurerm_network_interface.this.private_ip_address
}

# 🎓 WHY OUTPUT: Computer name may differ from VM name
# - Azure limits computer name to 15 characters
# - Important for AD join operations
output "vm_computer_name" {
  description = "The computer name (hostname) of the VM. May differ from vm_name due to Azure naming constraints (15 char limit)."
  value       = azurerm_windows_virtual_machine.this.computer_name
}

###################
# Network Information
###################

# 🎓 WHY OUTPUT: NIC ID needed for NSG associations
# - Attach NSG to specific NICs
# - Used for network security policies
output "network_interface_id" {
  description = "The resource ID of the network interface. Use for NSG associations or additional IP configurations."
  value       = azurerm_network_interface.this.id
}

# 🎓 WHY OUTPUT: Useful for networking troubleshooting
output "network_interface_name" {
  description = "The name of the network interface. Useful for Azure Portal lookups and troubleshooting."
  value       = azurerm_network_interface.this.name
}

###################
# Storage Information
###################

# 🎓 WHY OUTPUT: Data disk ID needed for snapshots
# - Create disk snapshots
# - Attach to different VMs
# - Disk management operations
output "data_disk_id" {
  description = "The resource ID of the data disk (if created). Use for snapshot operations or disk migrations. Will be null if create_data_disk = false."
  value       = var.create_data_disk ? azurerm_managed_disk.data[0].id : null
}

# 🎓 WHY OUTPUT: OS disk ID for backup/snapshots
output "os_disk_id" {
  description = "The resource ID of the OS disk. Use for snapshot operations or Azure Backup configuration."
  value       = azurerm_windows_virtual_machine.this.os_disk[0].name
}

###################
# Identity Information
###################

# 🎓 WHY OUTPUT: System-assigned identity for RBAC
# - Assign roles to VM's managed identity
# - Grant access to Key Vault, Storage, etc.
# - Used in zero-trust architectures
output "system_assigned_identity_principal_id" {
  description = "The Principal ID of the VM's system-assigned managed identity. Use for RBAC role assignments. Will be null if identity not enabled."
  value       = try(azurerm_windows_virtual_machine.this.identity[0].principal_id, null)
}

###################
# Composite Outputs (Advanced)
###################

# 🎓 TEACHING POINT: Complex object outputs
# - Return multiple related values as single output
# - Cleaner than many individual outputs
# - Easier to consume in calling code
output "vm_info" {
  description = "Complete VM information as an object. Contains id, name, private_ip, computer_name, and resource_group."
  value = {
    id                 = azurerm_windows_virtual_machine.this.id
    name               = azurerm_windows_virtual_machine.this.name
    computer_name      = azurerm_windows_virtual_machine.this.computer_name
    private_ip_address = azurerm_network_interface.this.private_ip_address
    resource_group     = azurerm_windows_virtual_machine.this.resource_group_name
    location           = azurerm_windows_virtual_machine.this.location
  }
}

# 🎓 EXAMPLE: How to use composite output in root configuration
# module.web_vm.vm_info.id
# module.web_vm.vm_info.name
# module.web_vm.vm_info.private_ip_address

###################
# Debugging Outputs (Optional - Comment out for production)
###################

# 🎓 TEACHING POINT: Debugging outputs
# - Useful during module development
# - Comment out or remove for production
# - Helps verify variable values and logic

# output "debug_vm_size" {
#   description = "DEBUG: VM size being used"
#   value       = var.vm_size
# }
#
# output "debug_disk_names" {
#   description = "DEBUG: Generated disk names"
#   value = {
#     nic       = local.nic_name
#     os_disk   = local.os_disk_name
#     data_disk = local.data_disk_name
#   }
# }
