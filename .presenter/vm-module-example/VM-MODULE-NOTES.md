# VM Module Conversion - Teaching Guide

## Overview

This example demonstrates converting a monolithic `vm.tf` file into a properly structured Terraform module following best practices. The conversion showcases:

- **Module structure** and file organization
- **Where each file type belongs** (backend.tf, provider.tf, data.tf, etc.)
- **Root vs Module separation** of concerns
- **Teaching points** explaining every design decision

## 📁 Directory Structure

```
vm-module-example/
├── vm.tf                          # ORIGINAL monolithic file
├── VM-MODULE-NOTES.md            # THIS FILE - Teaching guide
│
├── modules/                       # MODULE CODE (reusable)
│   └── azure-windows-vm/
│       ├── README.md              # Module documentation with examples
│       ├── main.tf                # Resource definitions
│       ├── variables.tf           # Input variables (module API)
│       ├── outputs.tf             # Output values
│       ├── versions.tf            # Terraform/provider version constraints
│       └── locals.tf              # Computed local values
│
└── environments/                  # ROOT CONFIGURATIONS (environment-specific)
    └── dev/
        ├── backend.tf             # State storage configuration
        ├── provider.tf            # Provider configuration
        ├── data.tf                # Data sources (existing resources)
        ├── main.tf                # Module calls and resource creation
        ├── variables.tf           # Environment variables
        ├── outputs.tf             # Environment outputs
        └── terraform.tfvars       # Variable values
```

## 🎯 File Placement Rules

### Files That Belong in **MODULES** (Reusable Code)

#### ✅ `main.tf`
- **Contains**: Resource definitions (VMs, disks, NICs)
- **Why Here**: Core module functionality
- **Teaching Point**: Modules are templates for creating resources

#### ✅ `variables.tf`
- **Contains**: Input variable declarations (no values!)
- **Why Here**: Defines module's API/interface
- **Teaching Point**: Variables make modules flexible and reusable

#### ✅ `outputs.tf`
- **Contains**: Output declarations
- **Why Here**: Expose information for module composition
- **Teaching Point**: Outputs enable one module to feed another

#### ✅ `versions.tf`
- **Contains**: Terraform and provider version constraints
- **Why Here**: Documents module requirements
- **Teaching Point**: Ensures compatibility across environments

#### ✅ `locals.tf`
- **Contains**: Computed local values
- **Why Here**: DRY principle within module
- **Teaching Point**: Calculate once, use many times

#### ✅ `README.md`
- **Contains**: Documentation, examples, usage
- **Why Here**: Every module should be self-documenting
- **Teaching Point**: Documentation is code!

---

### Files That Belong in **ROOT** (Environment-Specific)

#### ✅ `backend.tf`
- **Contains**: State storage configuration
- **Why Root**: Each environment has different state file
- **Teaching Point**: Dev/staging/prod have separate states
- **Module Placement**: ❌ **NEVER** in modules

```hcl
# ✅ CORRECT: environments/dev/backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstatedev"
    container_name       = "tfstate"
    key                  = "dev/vm-infra.tfstate"
    use_azuread_auth     = true
  }
}

# ❌ WRONG: modules/azure-windows-vm/backend.tf
# Don't do this! Modules don't manage state.
```

#### ✅ `provider.tf`
- **Contains**: Provider configuration
- **Why Root**: Each environment may use different subscriptions
- **Teaching Point**: Modules inherit provider from root
- **Module Placement**: ❌ **NEVER** in modules

```hcl
# ✅ CORRECT: environments/dev/provider.tf
provider "azurerm" {
  features {}
  subscription_id = "dev-subscription-id"
}

# ❌ WRONG: modules/azure-windows-vm/provider.tf
# Modules don't configure providers!
```

#### ✅ `data.tf`
- **Contains**: Data sources for existing resources
- **Why Root**: Queries environment-specific infrastructure
- **Teaching Point**: Root discovers, module receives IDs
- **Module Placement**: ❌ Usually not in modules (environment-specific)

```hcl
# ✅ CORRECT: environments/dev/data.tf
data "azurerm_subnet" "web" {
  name                 = "dev-web-subnet"
  virtual_network_name = "dev-vnet"
  resource_group_name  = "dev-networking-rg"
}

# ❌ WRONG: modules/azure-windows-vm/data.tf
# Don't query existing resources in modules - makes them environment-specific
```

#### ✅ `main.tf`
- **Contains**: Module calls, root-level resources
- **Why Root**: Composes modules for complete environment
- **Teaching Point**: Root orchestrates, modules execute
- **Module Placement**: ✅ Also in modules (but different content!)

```hcl
# ✅ CORRECT: environments/dev/main.tf
module "web_vm" {
  source = "../../modules/azure-windows-vm"
  
  vm_name     = "dev-web-01"
  subnet_id   = data.azurerm_subnet.web.id
  # ... other variables
}

# ✅ CORRECT: modules/azure-windows-vm/main.tf
resource "azurerm_windows_virtual_machine" "this" {
  # Resource definition
}
```

#### ✅ `variables.tf`
- **Contains**: Environment-level variables
- **Why Root**: Environment-specific inputs
- **Teaching Point**: Root variables feed multiple modules
- **Module Placement**: ✅ Also in modules (different variables!)

```hcl
# ✅ CORRECT: environments/dev/variables.tf
variable "environment" {
  description = "Environment name"
  default     = "dev"
}

# ✅ CORRECT: modules/azure-windows-vm/variables.tf
variable "vm_name" {
  description = "VM name"
  type        = string
}
```

#### ✅ `terraform.tfvars`
- **Contains**: Variable values
- **Why Root**: Environment-specific values
- **Teaching Point**: One .tfvars per environment
- **Module Placement**: ❌ **NEVER** in modules

```hcl
# ✅ CORRECT: environments/dev/terraform.tfvars
environment = "dev"
location    = "eastus"

# ❌ WRONG: modules/azure-windows-vm/terraform.tfvars
# Modules don't have .tfvars files!
```

---

## 🔄 Conversion Process

### Original File Structure (Monolithic)

The original `vm.tf` had everything in one file:

```hcl
# vm.tf (BEFORE - monolithic)
terraform { required_providers { ... } }      # Version constraints
provider "azurerm" { ... }                    # Provider config
data "azurerm_virtual_network" { ... }        # Data sources
data "azurerm_subnet" { ... }                 # More data sources
resource "azurerm_resource_group" { ... }     # Resource creation
resource "azurerm_network_interface" { ... }  # More resources
resource "azurerm_windows_virtual_machine" { ... }  # VM definition
```

**Problems:**
- ❌ Not reusable (hardcoded values)
- ❌ No separation of concerns
- ❌ Can't easily create multiple VMs
- ❌ No environment isolation
- ❌ Provider and backend mixed with resources

### Converted Structure (Modular)

**Step 1: Create Module**
- Extract resource definitions → `modules/azure-windows-vm/main.tf`
- Define inputs → `modules/azure-windows-vm/variables.tf`
- Expose outputs → `modules/azure-windows-vm/outputs.tf`
- Add version constraints → `modules/azure-windows-vm/versions.tf`
- Create locals for naming → `modules/azure-windows-vm/locals.tf`
- Write documentation → `modules/azure-windows-vm/README.md`

**Step 2: Create Root Configuration**
- Move provider config → `environments/dev/provider.tf`
- Move backend config → `environments/dev/backend.tf`
- Move data sources → `environments/dev/data.tf`
- Call module → `environments/dev/main.tf`
- Define environment vars → `environments/dev/variables.tf`
- Provide values → `environments/dev/terraform.tfvars`
- Add outputs → `environments/dev/outputs.tf`

---

## 📚 Key Design Decisions

### 1. **No Public IP by Default**
**Decision**: `enable_public_ip` not included
**Rationale**:
- Security best practice
- Use Azure Bastion or VPN
- Reduces attack surface
- Lower costs

**Teaching Point**: "VMs should never be internet-facing unless absolutely necessary. Use Bastion for admin access."

### 2. **Accelerated Networking Enabled**
**Decision**: Default `true`
**Rationale**:
- Free performance boost (30 Gbps vs 1-2 Gbps)
- Supported on D/E/F/H series
- No downside on supported VMs
- Industry best practice

**Teaching Point**: "Always enable accelerated networking on production VMs. It's free and dramatically improves performance."

### 3. **Premium_LRS for OS Disk**
**Decision**: Default `Premium_LRS`
**Rationale**:
- Required for 99.9% SLA
- Much faster than Standard (500+ IOPS vs 120)
- Only ~$5/month difference
- Production-ready default

**Teaching Point**: "Premium storage is essential for production. The cost difference is negligible compared to the performance and SLA benefits."

### 4. **Manual Patching Default**
**Decision**: `patch_mode = "Manual"`
**Rationale**:
- Enterprises need controlled patching windows
- Test patches in dev before prod
- Avoid surprise reboots
- Aligns with ITIL processes

**Teaching Point**: "Production systems need controlled maintenance windows. Use AutomaticByPlatform for non-critical dev/test."

### 5. **Boot Diagnostics Disabled**
**Decision**: Default `false`
**Rationale**:
- Costs money (storage account)
- Only needed for troubleshooting
- Enable on-demand when issues occur
- Saves costs in dev/test

**Teaching Point**: "Enable boot diagnostics for production VMs or when troubleshooting. Disable to save costs in dev/test."

### 6. **Data Disk Optional**
**Decision**: `create_data_disk = false` default
**Rationale**:
- Not all VMs need extra disks
- Flexibility for different use cases
- Best practice for databases (separate data/OS)
- User explicitly opts in

**Teaching Point**: "Always separate OS and data disks for databases. For web servers, OS disk may be sufficient."

### 7. **Hardcoded Image Publisher**
**Decision**: Publisher/offer hardcoded, SKU variable
**Rationale**:
- This is a Windows module (always Windows Server)
- Version (2019/2022/2025) should be flexible
- Reduces variables without losing flexibility
- Clear module purpose

**Teaching Point**: "Hardcode what never changes, parameterize what does. This is a Windows module, so publisher is fixed."

### 8. **Separate NIC Resource**
**Decision**: Separate NIC instead of inline
**Rationale**:
- Can be managed independently
- Allows NIC swap without VM recreation
- Enables multiple NICs
- Better for advanced scenarios

**Teaching Point**: "Separate NIC resources provide flexibility for advanced networking scenarios."

---

## 🎓 Teaching Scenarios

### Scenario 1: "Why can't I put provider {} in my module?"

**Student Question**: "The module should configure its own provider!"

**Answer**:
```hcl
# ❌ WRONG: In module
provider "azurerm" {
  subscription_id = "12345"  # What about other subscriptions?
}

# ✅ RIGHT: In root
provider "azurerm" {
  subscription_id = var.subscription_id  # Different per environment
}

module "vm" {
  source = "./modules/azure-windows-vm"
  # Module inherits provider from root
}
```

**Teaching Point**:
- Modules are reusable code templates
- Providers are runtime configuration
- Root controls WHERE resources are created
- Modules control WHAT resources are created

### Scenario 2: "Should I query existing VNet in the module?"

**Student Question**: "My module needs a VNet, should I query it inside?"

**Answer**:
```hcl
# ❌ WRONG: In module/main.tf
data "azurerm_virtual_network" "vnet" {
  name                = "prod-vnet"  # Hardcoded! Not reusable!
  resource_group_name = "networking-rg"
}

# ✅ RIGHT: In root/data.tf
data "azurerm_virtual_network" "vnet" {
  name                = "dev-vnet"  # Environment-specific
  resource_group_name = "dev-networking-rg"
}

data "azurerm_subnet" "web" {
  name                 = "web-subnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = "dev-networking-rg"
}

# Root/main.tf
module "vm" {
  source    = "./modules/azure-windows-vm"
  subnet_id = data.azurerm_subnet.web.id  # Pass ID to module
}
```

**Teaching Point**:
- Root discovers existing infrastructure
- Root passes resource IDs to modules
- Modules stay environment-agnostic
- One module works across all environments

### Scenario 3: "Where should terraform.tfvars go?"

**Student Question**: "Should each module have its own terraform.tfvars?"

**Answer**:
```
# ❌ WRONG Structure:
modules/
└── azure-windows-vm/
    └── terraform.tfvars  # NO! Modules don't have .tfvars

# ✅ RIGHT Structure:
environments/
├── dev/
│   └── terraform.tfvars      # Dev values
├── staging/
│   └── terraform.tfvars      # Staging values
└── prod/
    └── terraform.tfvars      # Prod values
```

**Teaching Point**:
- Modules define variables (API)
- Root provides values (data)
- One .tfvars per environment
- Modules never have variable values

---

## 🚀 Deployment Workflow

### Initial Setup

```powershell
# 1. Navigate to dev environment
cd environments/dev

# 2. Initialize Terraform
terraform init

# 3. Validate configuration
terraform validate

# 4. Format code
terraform fmt -recursive

# 5. Plan deployment
terraform plan -out=tfplan

# 6. Review plan carefully
# Check: resource counts, changes, data sources

# 7. Apply if plan looks good
terraform apply tfplan
```

### Making Changes

```powershell
# 1. Modify module or root config
code ../../modules/azure-windows-vm/variables.tf

# 2. Plan changes
terraform plan

# 3. If satisfied, apply
terraform apply
```

### Adding New VMs

```hcl
# In environments/dev/main.tf
module "new_vm" {
  source = "../../modules/azure-windows-vm"
  
  vm_name             = "dev-newapp-01"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = "eastus"
  subnet_id           = data.azurerm_subnet.app_subnet.id
  admin_username      = "azureadmin"
  admin_password      = data.azurerm_key_vault_secret.vm_admin_password.value
}
```

---

## 🎯 Common Mistakes to Avoid

### ❌ Mistake 1: Provider in Module
```hcl
# modules/azure-windows-vm/provider.tf (WRONG!)
provider "azurerm" {
  features {}
}
```
**Fix**: Remove provider from module. Configure in root only.

### ❌ Mistake 2: Backend in Module
```hcl
# modules/azure-windows-vm/backend.tf (WRONG!)
terraform {
  backend "azurerm" { ... }
}
```
**Fix**: Remove backend from module. Configure in root only.

### ❌ Mistake 3: Data Sources in Module
```hcl
# modules/azure-windows-vm/main.tf (WRONG!)
data "azurerm_subnet" "web" {
  name = "prod-web-subnet"  # Environment-specific!
}
```
**Fix**: Move data sources to root, pass IDs as variables.

### ❌ Mistake 4: Hardcoded Values in Module
```hcl
# modules/azure-windows-vm/main.tf (WRONG!)
resource "azurerm_windows_virtual_machine" "this" {
  location = "eastus"  # Hardcoded!
}
```
**Fix**: Use variables for all environment-specific values.

### ❌ Mistake 5: Module Calls Module Directly
```hcl
# modules/azure-windows-vm/main.tf (WRONG!)
module "networking" {
  source = "../azure-networking"
}
```
**Fix**: Module composition happens in root, not in modules.

---

## ✅ Checklist for Students

### Module Creation
- [ ] Created `modules/azure-windows-vm/` directory
- [ ] All resource definitions in `main.tf`
- [ ] All inputs in `variables.tf` with descriptions
- [ ] All outputs in `outputs.tf` with descriptions
- [ ] Version constraints in `versions.tf`
- [ ] Local values in `locals.tf`
- [ ] Comprehensive `README.md`
- [ ] NO `provider.tf` in module
- [ ] NO `backend.tf` in module
- [ ] NO environment-specific values in module

### Root Configuration
- [ ] Created `environments/dev/` directory
- [ ] Backend config in `backend.tf`
- [ ] Provider config in `provider.tf`
- [ ] Data sources in `data.tf`
- [ ] Module calls in `main.tf`
- [ ] Environment variables in `variables.tf`
- [ ] Variable values in `terraform.tfvars`
- [ ] Outputs in `outputs.tf`
- [ ] NO module code in root

### Best Practices
- [ ] All variables have descriptions
- [ ] Sensitive variables marked `sensitive = true`
- [ ] Validation rules where appropriate
- [ ] Sensible defaults in module
- [ ] Common tags via locals
- [ ] Secrets from Key Vault (not hardcoded)
- [ ] Resource naming via locals
- [ ] Teaching comments throughout

---

## 📖 Additional Resources

- Module README: `modules/azure-windows-vm/README.md`
- Terraform Modules Guide: https://developer.hashicorp.com/terraform/language/modules
- Azure Provider Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- Best Practices Guide: `../../LAB3-TF-MODULE.md`

---

**Last Updated**: November 23, 2025
**Version**: 1.0
**Author**: DevOps Team
