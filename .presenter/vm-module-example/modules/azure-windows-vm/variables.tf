# 🎓 Teaching Point: Module Variables
# Variables define the module's API - what inputs the module accepts.
# These match the original vm.tf requirements.

# VM Configuration
variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine (e.g., Standard_D4s_v5)"
  type        = string
  default     = "Standard_D4s_v5"
}

# Resource Group
variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

# Existing Network (Data Source Inputs)
variable "existing_vnet_name" {
  description = "Name of the existing virtual network"
  type        = string
}

variable "vnet_resource_group_name" {
  description = "Resource group where the VNet exists"
  type        = string
}

variable "existing_subnet_name" {
  description = "Name of the existing subnet"
  type        = string
}

# Authentication
variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

# OS Image
variable "os_sku" {
  description = "Windows Server SKU (e.g., 2019-datacenter, 2022-datacenter, 2025-datacenter)"
  type        = string
  default     = "2025-datacenter"
}

# Data Disk
variable "data_disk_size_gb" {
  description = "Size of the data disk in GB"
  type        = number
  default     = 128
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# 🎓 Teaching Point: Variable Best Practices
# - Always include descriptions
# - Use type constraints
# - Mark sensitive variables as sensitive
# - Provide reasonable defaults where appropriate
# - Group related variables together
