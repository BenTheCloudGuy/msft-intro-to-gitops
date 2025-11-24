# VM Module - Simplified Version

## What Changed

The module has been simplified to match the original `vm.tf` file structure. It now creates only the resources that were in the original file:

### Resources Created by Module

1. **Resource Group** - Container for all VM resources
2. **Network Interface** - VM's network connection
3. **Windows Virtual Machine** - The actual VM
4. **Managed Disk** - Data disk for the VM
5. **Disk Attachment** - Attaches data disk to VM

### Data Sources (Queries Existing Resources)

The module queries existing networking infrastructure:
- **Virtual Network** - Existing VNet
- **Subnet** - Existing subnet within the VNet

## Key Differences from Complex Version

### What Was Removed

❌ **Backend Configuration** - Removed from module (belongs in root if needed)
❌ **Provider Configuration** - Removed from module (belongs in root)
❌ **Key Vault Integration** - Removed (passwords passed directly as variables)
❌ **Complex Locals** - Removed (simpler naming now)
❌ **Optional Data Disk** - Now always created (matches original)
❌ **Multiple Environment Files** - Simplified to just main.tf

### What Was Kept

✅ **Teaching Comments** - All 🎓 teaching points preserved
✅ **Best Practices** - Accelerated networking, Premium storage, etc.
✅ **Variable Descriptions** - Clear documentation
✅ **Module Structure** - Proper separation of main.tf, variables.tf, outputs.tf

## File Structure

```
vm-module-example/
├── vm.tf                          # ORIGINAL file (before modularization)
│
├── modules/azure-windows-vm/      # MODULE (reusable)
│   ├── main.tf                    # Resource definitions + data sources
│   ├── variables.tf               # Input variables
│   ├── outputs.tf                 # Output values
│   ├── versions.tf                # Version constraints
│   └── README.md                  # Module documentation
│
└── environments/dev/              # EXAMPLE USAGE
    └── main.tf                    # Example module call
```

## How to Use

### 1. Ensure Prerequisites Exist

Before using the module, you need:
- An existing Virtual Network
- An existing Subnet within that VNet

### 2. Call the Module

```hcl
module "my_vm" {
  source = "../../modules/azure-windows-vm"

  # VM Configuration
  vm_name             = "myvm01"
  vm_size             = "Standard_D4s_v5"
  resource_group_name = "my-vm-rg"
  location            = "eastus"

  # Network Configuration (existing resources)
  existing_vnet_name       = "my-vnet"
  vnet_resource_group_name = "my-networking-rg"
  existing_subnet_name     = "my-subnet"

  # Authentication
  admin_username = "azureadmin"
  admin_password = "YourSecurePassword123!"

  # Optional: Override defaults
  os_sku            = "2022-datacenter"
  data_disk_size_gb = 256

  # Tags
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

### 3. Deploy

```powershell
cd environments/dev
terraform init
terraform plan
terraform apply
```

## Variables Reference

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `vm_name` | Name of the VM | `"myvm01"` |
| `resource_group_name` | Resource group to create | `"my-vm-rg"` |
| `location` | Azure region | `"eastus"` |
| `existing_vnet_name` | Existing VNet name | `"my-vnet"` |
| `vnet_resource_group_name` | VNet's resource group | `"networking-rg"` |
| `existing_subnet_name` | Existing subnet name | `"my-subnet"` |
| `admin_username` | VM admin username | `"azureadmin"` |
| `admin_password` | VM admin password | `"SecurePass123!"` |

### Optional Variables (with defaults)

| Variable | Default | Description |
|----------|---------|-------------|
| `vm_size` | `"Standard_D4s_v5"` | VM size |
| `os_sku` | `"2025-datacenter"` | Windows Server SKU |
| `data_disk_size_gb` | `128` | Data disk size in GB |
| `tags` | `{}` | Resource tags |

## Outputs

The module exposes these outputs:

- `resource_group_name` - Name of created resource group
- `resource_group_id` - ID of created resource group
- `vm_id` - Virtual machine ID
- `vm_name` - Virtual machine name
- `vm_private_ip` - VM's private IP address
- `nic_id` - Network interface ID
- `data_disk_id` - Data disk ID
- `data_disk_name` - Data disk name

## Design Decisions

### 1. Data Sources in Module

**Decision**: Include VNet/subnet data sources in the module  
**Why**: Matches the original vm.tf pattern  
**Tradeoff**: Less flexible than passing subnet_id from root  
**Teaching Point**: Shows both approaches are valid

### 2. Always Create Data Disk

**Decision**: Data disk always created (not optional)  
**Why**: Matches original vm.tf behavior  
**Tradeoff**: Can't skip data disk for simple VMs  
**Future**: Could add `create_data_disk` boolean variable

### 3. Hardcoded Best Practices

**Decision**: Some settings hardcoded (Premium_LRS, Accelerated Networking)  
**Why**: Enforce best practices  
**Tradeoff**: Less flexibility  
**Teaching Point**: Variables vs hardcoded values balance

### 4. Simple Naming

**Decision**: NIC/disk names derived from vm_name  
**Why**: Simple and predictable  
**Tradeoff**: No environment prefixes  
**Teaching Point**: Naming conventions can be complex or simple

## Comparison: Original vs Module

### Original vm.tf
```hcl
terraform { ... }
provider "azurerm" { ... }
data "azurerm_virtual_network" { ... }
data "azurerm_subnet" { ... }
resource "azurerm_resource_group" { ... }
resource "azurerm_network_interface" { ... }
resource "azurerm_windows_virtual_machine" { ... }
resource "azurerm_managed_disk" { ... }
resource "azurerm_virtual_machine_data_disk_attachment" { ... }
```

### Module main.tf
```hcl
# NO terraform block (in versions.tf)
# NO provider block (belongs in root)
data "azurerm_virtual_network" { ... }      # Same
data "azurerm_subnet" { ... }               # Same
resource "azurerm_resource_group" { ... }   # Same
resource "azurerm_network_interface" { ... } # Same
resource "azurerm_windows_virtual_machine" { ... } # Same
resource "azurerm_managed_disk" { ... }     # Same
resource "azurerm_virtual_machine_data_disk_attachment" { ... } # Same
```

**Key Difference**: Provider/backend moved to root, resources stay in module

## Teaching Points Summary

### Why Use Modules?

✅ **Reusability** - Define once, use many times  
✅ **Consistency** - Same configuration every time  
✅ **Maintainability** - Update in one place  
✅ **Testing** - Test module independently  
✅ **Documentation** - Self-contained with README  

### When NOT to Use Modules?

❌ One-off resources  
❌ Highly environment-specific code  
❌ Overly simple resources (single resource modules often overkill)  
❌ Rapid prototyping (modules add structure overhead)  

## Next Steps

1. **Test the module** - Deploy to dev environment
2. **Add features** - Optional data disk, public IP, etc.
3. **Create tests** - Terratest or terraform-compliance
4. **Publish** - Terraform Registry or private registry
5. **Use in production** - Create prod environment

## Questions?

See the module README.md for detailed documentation and examples.
