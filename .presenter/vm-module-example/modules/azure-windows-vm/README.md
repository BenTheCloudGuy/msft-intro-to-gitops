# Azure Windows VM Module

## Description

This module creates an Azure Windows Virtual Machine with best practices built-in, including:
- Managed disks support (OS and data disks)
- Network interface configuration
- Optional public IP assignment
- Configurable VM sizing and OS versions
- Boot diagnostics support
- Tagging strategy
- Security best practices

## 🎓 Teaching Points

### Why This Module Structure?

**1. Separation of Concerns**
- Each file has a specific purpose (main.tf = resources, variables.tf = inputs, etc.)
- Makes code easier to navigate and maintain
- Standard structure recognized across the industry

**2. Reusability**
- One module definition used across dev/staging/prod
- Consistent VM configuration everywhere
- Reduces duplicate code by ~80%

**3. Encapsulation**
- Complex VM setup hidden behind simple interface
- Users provide ~10 variables instead of managing 50+ resource properties
- Opinionated defaults based on Azure best practices

**4. Maintainability**
- Update VM security settings once, applies everywhere
- Version control allows rollback if issues occur
- Centralized testing and validation

## Usage

### Basic Example

```hcl
module "web_vm" {
  source = "../../modules/azure-windows-vm"
  
  vm_name             = "web-server-01"
  resource_group_name = "production-rg"
  location            = "eastus"
  
  subnet_id          = module.networking.subnet_ids["web"]
  admin_username     = "azureadmin"
  admin_password     = data.azurerm_key_vault_secret.vm_password.value
  
  vm_size            = "Standard_D4s_v5"
  windows_sku        = "2022-datacenter"
  
  tags = {
    Environment = "Production"
    Application = "WebServer"
    ManagedBy   = "Terraform"
  }
}
```

### Complete Example with Data Disk

```hcl
module "sql_vm" {
  source = "../../modules/azure-windows-vm"
  
  # Required variables
  vm_name             = "sql-server-01"
  resource_group_name = azurerm_resource_group.database.name
  location            = "eastus"
  subnet_id           = data.azurerm_subnet.database.id
  admin_username      = "sqladmin"
  admin_password      = data.azurerm_key_vault_secret.sql_password.value
  
  # VM Configuration
  vm_size                  = "Standard_E8s_v5"  # Memory-optimized for SQL
  windows_sku              = "2022-datacenter"
  license_type             = "Windows_Server"    # Hybrid benefit
  
  # Data Disk for SQL database files
  create_data_disk         = true
  data_disk_size_gb        = 512
  data_disk_caching        = "ReadOnly"          # SQL best practice
  data_disk_storage_type   = "Premium_LRS"
  
  # Networking
  enable_accelerated_networking = true
  
  # Management
  enable_boot_diagnostics  = true
  patch_mode              = "AutomaticByPlatform"  # Managed patching
  
  # Tagging
  tags = {
    Environment = "Production"
    Application = "SQLServer"
    Criticality = "High"
    ManagedBy   = "Terraform"
  }
}
```

### Using Existing VNet (Data Sources)

```hcl
# In your root configuration, not in the module
data "azurerm_virtual_network" "existing" {
  name                = "prod-vnet"
  resource_group_name = "networking-rg"
}

data "azurerm_subnet" "existing" {
  name                 = "database-subnet"
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = "networking-rg"
}

module "database_vm" {
  source = "../../modules/azure-windows-vm"
  
  vm_name             = "db-vm-01"
  resource_group_name = "database-rg"
  location            = "eastus"
  
  # Pass the subnet ID from data source
  subnet_id          = data.azurerm_subnet.existing.id
  
  admin_username     = "dbadmin"
  admin_password     = var.admin_password
  
  vm_size            = "Standard_D4s_v5"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | ~> 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vm_name | Name of the virtual machine | `string` | n/a | yes |
| resource_group_name | Resource group name where VM will be created | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| subnet_id | ID of the subnet for the VM's network interface | `string` | n/a | yes |
| admin_username | Administrator username | `string` | n/a | yes |
| admin_password | Administrator password | `string` | n/a | yes |
| vm_size | Azure VM size | `string` | `"Standard_D2s_v5"` | no |
| windows_sku | Windows Server SKU | `string` | `"2022-datacenter"` | no |
| license_type | License type for hybrid benefit | `string` | `"Windows_Server"` | no |
| os_disk_caching | OS disk caching type | `string` | `"ReadWrite"` | no |
| os_disk_storage_type | OS disk storage account type | `string` | `"Premium_LRS"` | no |
| create_data_disk | Whether to create an additional data disk | `bool` | `false` | no |
| data_disk_size_gb | Size of data disk in GB | `number` | `128` | no |
| data_disk_caching | Data disk caching type | `string` | `"ReadWrite"` | no |
| data_disk_storage_type | Data disk storage account type | `string` | `"Premium_LRS"` | no |
| enable_accelerated_networking | Enable accelerated networking | `bool` | `true` | no |
| enable_boot_diagnostics | Enable boot diagnostics | `bool` | `false` | no |
| patch_mode | Patch mode for the VM | `string` | `"Manual"` | no |
| enable_automatic_updates | Enable automatic updates | `bool` | `false` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vm_id | Resource ID of the virtual machine |
| vm_name | Name of the virtual machine |
| vm_private_ip | Private IP address of the VM |
| network_interface_id | ID of the network interface |
| data_disk_id | ID of the data disk (if created) |

## 🎯 Design Decisions & Teaching Points

### Why We Made These Choices

**1. No Public IP by Default**
- **Security First**: VMs should not be exposed to internet unless explicitly needed
- **Bastion/Jump Box Pattern**: Use Azure Bastion or jump box for admin access
- **Teaching Point**: Public IPs increase attack surface and cost

**2. Accelerated Networking Enabled by Default**
- **Performance**: Up to 30 Gbps throughput vs 1-2 Gbps without
- **Lower Latency**: Reduced network hops
- **No Extra Cost**: Free feature on supported VM sizes
- **Teaching Point**: Always enable when supported (D/E/F/H series VMs)

**3. Premium_LRS for OS Disk Default**
- **Performance**: Much faster than Standard_LRS (120 IOPS vs 500+ IOPS)
- **SLA**: Required for 99.9% single VM SLA
- **Cost**: Minimal difference (~$5/month) for significant benefit
- **Teaching Point**: Production VMs should always use Premium storage

**4. Manual Patching Default**
- **Control**: Organizations need patching windows
- **Testing**: Patches tested in dev before prod
- **Rollback**: Can revert problematic updates
- **Teaching Point**: Use `AutomaticByPlatform` for non-critical VMs

**5. Boot Diagnostics Disabled by Default**
- **Cost**: Requires storage account ($)
- **Opt-In**: Enable only when needed for troubleshooting
- **Teaching Point**: Enable for production VMs, disable for dev/test

**6. Data Disk Optional**
- **Flexibility**: Not all VMs need extra disks
- **Separation**: Separate OS and data (SQL best practice)
- **Teaching Point**: Always separate data from OS disk for databases

**7. License Type = Windows_Server**
- **Cost Savings**: Azure Hybrid Benefit saves ~40% on Windows licensing
- **Requirement**: Must have active Software Assurance
- **Teaching Point**: Always use for organizations with EA agreements

**8. Hardcoded publisher/offer**
- **Consistency**: Ensures Windows Server image
- **Flexibility**: SKU (version) is variable
- **Teaching Point**: Separate what changes (version) from what doesn't (publisher)

## Module File Structure Explanation

```
modules/azure-windows-vm/
├── README.md           # THIS FILE - Documentation and examples
├── main.tf             # Resource definitions (VM, NIC, Disk)
├── variables.tf        # Input variable declarations
├── outputs.tf          # Output value definitions
├── versions.tf         # Terraform and provider version constraints
└── locals.tf           # Local value calculations
```

### Why NOT Include in Module:

**❌ backend.tf**
- **Reason**: Backend config is workspace-specific, not module-specific
- **Location**: Root configuration only
- **Teaching Point**: Each environment (dev/prod) has different state backend

**❌ provider.tf**
- **Reason**: Provider config is root-level concern
- **Location**: Root configuration only
- **Teaching Point**: Modules inherit providers from calling configuration

**❌ terraform.tfvars**
- **Reason**: Variable values are environment-specific
- **Location**: Root configuration per environment
- **Teaching Point**: Modules define variables, root provides values

**❌ data.tf (for existing resources)**
- **Reason**: Data sources for existing VNets/subnets belong in root
- **Location**: Root configuration (pass subnet_id to module)
- **Teaching Point**: Keep infrastructure discovery at root level

## Example Project Structure

```
terraform-infrastructure/
├── environments/
│   ├── dev/
│   │   ├── main.tf              # Module calls
│   │   ├── variables.tf         # Root variables
│   │   ├── outputs.tf           # Root outputs
│   │   ├── backend.tf           # Dev state backend
│   │   ├── provider.tf          # Dev provider config
│   │   ├── data.tf              # Data sources for existing resources
│   │   └── terraform.tfvars     # Dev variable values
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── backend.tf           # Staging state backend
│   │   ├── provider.tf          # Staging provider config
│   │   ├── data.tf
│   │   └── terraform.tfvars     # Staging variable values
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── backend.tf           # Prod state backend
│       ├── provider.tf          # Prod provider config
│       ├── data.tf
│       └── terraform.tfvars     # Prod variable values (NO SECRETS!)
│
└── modules/
    └── azure-windows-vm/
        ├── README.md
        ├── main.tf              # Module resources
        ├── variables.tf         # Module inputs
        ├── outputs.tf           # Module outputs
        ├── versions.tf          # Module version constraints
        └── locals.tf            # Module locals
```

## Best Practices Demonstrated

✅ **Security**
- No public IPs by default
- Passwords via variables (use Key Vault in production)
- Accelerated networking for performance
- Premium storage for SLA

✅ **Maintainability**
- Clear variable descriptions
- Sensible defaults
- Consistent naming conventions
- Comprehensive outputs

✅ **Reusability**
- Environment-agnostic module
- Flexible configuration options
- No hardcoded values (except Azure image publisher)

✅ **Documentation**
- Complete README with examples
- Inline comments explaining decisions
- Teaching points for students

## Common Patterns

### Pattern 1: Multiple VMs in Same Environment

```hcl
module "web_vm_01" {
  source = "../../modules/azure-windows-vm"
  vm_name = "web-vm-01"
  # ... config
}

module "web_vm_02" {
  source = "../../modules/azure-windows-vm"
  vm_name = "web-vm-02"
  # ... config
}
```

### Pattern 2: Using for_each for Multiple VMs

```hcl
locals {
  vms = {
    web-01 = {
      vm_size = "Standard_D2s_v5"
      subnet  = "web"
    }
    web-02 = {
      vm_size = "Standard_D2s_v5"
      subnet  = "web"
    }
    app-01 = {
      vm_size = "Standard_D4s_v5"
      subnet  = "app"
    }
  }
}

module "vms" {
  for_each = local.vms
  
  source = "../../modules/azure-windows-vm"
  
  vm_name             = each.key
  vm_size             = each.value.vm_size
  subnet_id           = module.networking.subnet_ids[each.value.subnet]
  resource_group_name = azurerm_resource_group.compute.name
  location            = "eastus"
  admin_username      = var.admin_username
  admin_password      = data.azurerm_key_vault_secret.vm_password.value
}
```

## Testing Checklist

- [ ] Run `terraform fmt` to format code
- [ ] Run `terraform validate` to check syntax
- [ ] Test module in dev environment first
- [ ] Verify VM boots successfully
- [ ] Check accelerated networking is enabled
- [ ] Confirm data disk is attached (if created)
- [ ] Review Azure costs in dev before prod deployment
- [ ] Test VM connectivity (RDP/WinRM)
- [ ] Verify tags are applied correctly

## Troubleshooting

**Issue**: "Accelerated networking not supported"
- **Cause**: VM size doesn't support it
- **Fix**: Use D/E/F/H series VMs or set `enable_accelerated_networking = false`

**Issue**: "Subnet not found"
- **Cause**: Incorrect subnet_id or data source
- **Fix**: Verify data source in root config matches actual subnet

**Issue**: "Password doesn't meet complexity requirements"
- **Cause**: Azure requires complex passwords
- **Fix**: Use 12+ chars with uppercase, lowercase, numbers, symbols

## Further Reading

- [Azure VM Best Practices](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/overview)
- [Azure VM Sizing Guide](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes)
- [Accelerated Networking](https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview)
- [Azure Hybrid Benefit](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/hybrid-use-benefit-licensing)
