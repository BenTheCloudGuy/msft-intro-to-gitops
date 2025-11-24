# Quick Start Guide - VM Module Example

## 🎯 What This Example Demonstrates

This is a **complete working example** showing how to convert a monolithic Terraform configuration into a properly structured module following best practices.

### What You'll Learn

✅ **Where files belong**: backend.tf, provider.tf, data.tf placement  
✅ **Module vs Root**: Separation of concerns  
✅ **Best practices**: Security, performance, maintainability  
✅ **Teaching points**: WHY each decision was made  

---

## 📁 What's Included

```
vm-module-example/
├── vm.tf                          # ORIGINAL monolithic file (BEFORE)
├── VM-MODULE-NOTES.md             # Comprehensive teaching guide
├── QUICKSTART.md                  # This file
│
├── modules/                       # REUSABLE MODULE
│   └── azure-windows-vm/
│       ├── README.md              # Module documentation
│       ├── main.tf                # Resource definitions
│       ├── variables.tf           # Input variables
│       ├── outputs.tf             # Output values
│       ├── versions.tf            # Version constraints
│       └── locals.tf              # Computed values
│
└── environments/                  # ENVIRONMENT-SPECIFIC CONFIG
    └── dev/
        ├── backend.tf             # ⭐ State storage config
        ├── provider.tf            # ⭐ Azure provider config
        ├── data.tf                # ⭐ Existing resource queries
        ├── main.tf                # Module calls
        ├── variables.tf           # Environment variables
        ├── outputs.tf             # Environment outputs
        └── terraform.tfvars       # Variable values
```

---

## 🚀 5-Minute Setup

### Prerequisites

```powershell
# 1. Terraform installed
terraform version  # Should be >= 1.5.0

# 2. Azure CLI installed
az --version

# 3. Authenticated to Azure
az login

# 4. Set subscription (replace with your subscription ID)
az account set --subscription "YOUR-SUBSCRIPTION-ID"
```

### Before You Deploy - **IMPORTANT CUSTOMIZATION REQUIRED**

**⚠️ This example will NOT work out-of-the-box!** You must customize these files:

#### 1. `environments/dev/backend.tf` - Update state storage
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "YOUR-STATE-RG"        # ⬅️ CHANGE THIS
    storage_account_name = "YOUR-STATE-STORAGE"   # ⬅️ CHANGE THIS
    container_name       = "tfstate"
    key                  = "dev/vm-infra.tfstate"
    use_azuread_auth     = true
  }
}
```

**How to create state storage:**
```powershell
# Create resource group for state
az group create --name terraform-state-rg --location eastus

# Create storage account (must be globally unique)
az storage account create `
  --name tfstate$(Get-Random -Maximum 99999) `
  --resource-group terraform-state-rg `
  --location eastus `
  --sku Standard_LRS `
  --encryption-services blob

# Create container
az storage container create `
  --name tfstate `
  --account-name YOUR-STORAGE-ACCOUNT-NAME `
  --auth-mode login
```

#### 2. `environments/dev/provider.tf` - Update subscription
```hcl
provider "azurerm" {
  features { ... }
  subscription_id = "YOUR-SUBSCRIPTION-ID"  # ⬅️ CHANGE THIS
}
```

#### 3. `environments/dev/data.tf` - Update existing resource names
```hcl
data "azurerm_virtual_network" "main" {
  name                = "YOUR-VNET-NAME"      # ⬅️ CHANGE THIS
  resource_group_name = "YOUR-NETWORK-RG"     # ⬅️ CHANGE THIS
}

data "azurerm_subnet" "web" {
  name                 = "YOUR-SUBNET-NAME"   # ⬅️ CHANGE THIS
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = "YOUR-NETWORK-RG"    # ⬅️ CHANGE THIS
}

data "azurerm_key_vault" "main" {
  name                = "YOUR-KV-NAME"        # ⬅️ CHANGE THIS
  resource_group_name = "YOUR-KV-RG"          # ⬅️ CHANGE THIS
}
```

**How to create prerequisites:**
```powershell
# Create resource group for networking
az group create --name dev-networking-rg --location eastus

# Create VNet
az network vnet create `
  --resource-group dev-networking-rg `
  --name dev-vnet `
  --address-prefix 10.0.0.0/16 `
  --subnet-name dev-web-subnet `
  --subnet-prefix 10.0.1.0/24

# Create Key Vault (name must be globally unique)
az keyvault create `
  --name kv-dev-$(Get-Random -Maximum 99999) `
  --resource-group dev-networking-rg `
  --location eastus `
  --enable-rbac-authorization true

# Add VM admin password secret
az keyvault secret set `
  --vault-name YOUR-KV-NAME `
  --name vm-admin-password `
  --value "YourSecurePassword123!"
```

#### 4. `environments/dev/terraform.tfvars` - Update values
```hcl
environment = "dev"
location    = "eastus"  # ⬅️ CHANGE if needed
project     = "myproject"  # ⬅️ CHANGE THIS
```

---

## ✅ Deploy the Example

### Step 1: Navigate to Dev Environment
```powershell
cd environments/dev
```

### Step 2: Initialize Terraform
```powershell
terraform init
```

**Expected output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "~> 4.0"...
Terraform has been successfully initialized!
```

### Step 3: Validate Configuration
```powershell
terraform validate
```

**Expected output:**
```
Success! The configuration is valid.
```

### Step 4: Format Code
```powershell
terraform fmt -recursive
```

### Step 5: Plan Deployment
```powershell
terraform plan -out=tfplan
```

**Review the plan carefully:**
- ✅ Check resource count (should be ~15-20 resources)
- ✅ Verify VM names, sizes, locations
- ✅ Confirm data sources found existing resources
- ✅ No unexpected deletions

### Step 6: Apply Configuration
```powershell
terraform apply tfplan
```

**Wait 5-10 minutes for deployment to complete.**

---

## 🎓 Learning Exercise: Create a New VM

### Task: Add a new application server VM

**Edit `environments/dev/main.tf`** and add:

```hcl
module "new_app_vm" {
  source = "../../modules/azure-windows-vm"
  
  # Basic Configuration
  vm_name             = "dev-newapp-01"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = var.location
  
  # Networking
  subnet_id = data.azurerm_subnet.app.id
  
  # VM Size
  vm_size = "Standard_D4s_v5"  # 4 vCPU, 16 GB RAM
  
  # Image
  os_sku    = "2022-datacenter-azure-edition"
  os_version = "latest"
  
  # Authentication
  admin_username = "azureadmin"
  admin_password = data.azurerm_key_vault_secret.vm_admin_password.value
  
  # Storage
  os_disk_size_gb  = 128
  create_data_disk = true
  data_disk_size_gb = 512
  
  # Tags
  tags = merge(
    local.common_tags,
    {
      Role = "Application Server"
      Owner = "DevTeam"
    }
  )
}
```

**Then deploy:**
```powershell
terraform plan
terraform apply
```

**Teaching Points:**
- ✅ Reusing the module for different VMs
- ✅ Customizing per-VM settings
- ✅ Merging tags for consistency
- ✅ Module flexibility

---

## 🔍 Exploring the Code

### Key Files to Review

#### 1. **Module Definition** (`modules/azure-windows-vm/main.tf`)
```powershell
code ../../modules/azure-windows-vm/main.tf
```
**Look for:**
- Resource definitions
- `🎓 Teaching Point` comments
- Variable references (`var.xxx`)
- Local references (`local.xxx`)

#### 2. **Module API** (`modules/azure-windows-vm/variables.tf`)
```powershell
code ../../modules/azure-windows-vm/variables.tf
```
**Look for:**
- Required vs optional variables
- Validation rules
- Default values
- Descriptions

#### 3. **Root Configuration** (`environments/dev/main.tf`)
```powershell
code main.tf
```
**Look for:**
- Module calls
- Data source usage
- Resource composition

#### 4. **File Placement** (`VM-MODULE-NOTES.md`)
```powershell
code ../../VM-MODULE-NOTES.md
```
**Learn:**
- Where backend.tf belongs
- Where provider.tf belongs
- Where data.tf belongs
- Common mistakes

---

## 🎯 Teaching Scenarios

### Scenario 1: "Why isn't backend.tf in the module?"

**Answer**: Each environment (dev/staging/prod) needs its own state file. Modules are reusable code, so they can't have backend configuration.

```
# ✅ CORRECT Structure:
environments/
├── dev/
│   └── backend.tf        # Dev state
├── staging/
│   └── backend.tf        # Staging state
└── prod/
    └── backend.tf        # Prod state

modules/
└── azure-windows-vm/
    └── [NO backend.tf]   # Module doesn't manage state!
```

### Scenario 2: "Should I query the VNet in my module?"

**Answer**: No! Data sources query existing environment-specific infrastructure, so they belong in root.

```hcl
# ❌ WRONG: In module
data "azurerm_subnet" "web" {
  name = "prod-web-subnet"  # Hardcoded to prod!
}

# ✅ RIGHT: In root
data "azurerm_subnet" "web" {
  name = "dev-web-subnet"  # Environment-specific
}

# Root passes to module
module "vm" {
  source    = "./modules/azure-windows-vm"
  subnet_id = data.azurerm_subnet.web.id  # Pass ID
}
```

### Scenario 3: "How do I use this in production?"

**Answer**: Create `environments/prod/` with different values.

```powershell
# Copy dev environment
cp -r environments/dev environments/prod

# Edit prod files
cd environments/prod

# Update backend.tf
# - Different state file key
# - Maybe different storage account

# Update provider.tf
# - Different subscription_id

# Update data.tf
# - prod-vnet instead of dev-vnet
# - prod-networking-rg instead of dev-networking-rg

# Update terraform.tfvars
# - environment = "prod"
# - Larger VM sizes
# - Different locations

# Deploy
terraform init
terraform plan
terraform apply
```

---

## 🧹 Cleanup

### Remove All Resources
```powershell
# In environments/dev/
terraform destroy
```

**Type `yes` when prompted.**

### Remove State Storage (Optional)
```powershell
az group delete --name terraform-state-rg --yes --no-wait
```

---

## 📚 Next Steps

1. **Read VM-MODULE-NOTES.md** - Comprehensive teaching guide
2. **Modify the module** - Add public IP support, availability zones
3. **Create staging environment** - Copy and customize dev
4. **Write tests** - Use Terratest or terraform-compliance
5. **Publish module** - Terraform Registry or private registry

---

## ❓ Common Questions

### Q: Can I use this module for Linux VMs?
**A**: No, this is specifically for Windows VMs. You'd need a separate `azure-linux-vm` module with different image publisher and no Windows licensing.

### Q: Why are VMs named with numbers (dev-web-01)?
**A**: Standard naming convention supporting multiple instances. Use `for_each` to create multiple VMs programmatically.

### Q: Should I commit terraform.tfvars to Git?
**A**: **NO!** Contains sensitive values. Add to `.gitignore`. Use `terraform.tfvars.example` for documentation.

### Q: Can I use this module in a different Azure subscription?
**A**: Yes! Update `provider.tf` with different `subscription_id`. Module is subscription-agnostic.

### Q: How do I enable public IP?
**A**: Not implemented by design (security best practice). Use Azure Bastion instead. If needed, add `enable_public_ip` variable to module.

---

## 🆘 Troubleshooting

### Error: Backend initialization failed
```
Error: Failed to get existing workspaces: storage account not found
```
**Solution**: Create state storage account first (see "Before You Deploy" section).

### Error: Data source not found
```
Error: Error retrieving Virtual Network "dev-vnet": network.VirtualNetworksClient#Get: Failure responding to request
```
**Solution**: Create VNet first or update `data.tf` with existing VNet name.

### Error: Key Vault secret not found
```
Error: Error retrieving Secret "vm-admin-password": keyvault.BaseClient#GetSecret: Failure responding to request
```
**Solution**: Create secret in Key Vault or use a different secret name.

### Error: Insufficient quota
```
Error: Code="QuotaExceeded" Message="Operation could not be completed as it results in exceeding approved standardDSv5Family Cores quota"
```
**Solution**: Request quota increase or use smaller VM size.

---

## 📖 Additional Resources

- **Module README**: `modules/azure-windows-vm/README.md`
- **Teaching Notes**: `VM-MODULE-NOTES.md`
- **Best Practices Guide**: `../../LAB3-TF-MODULE.md`
- **Terraform Docs**: https://developer.hashicorp.com/terraform
- **Azure Provider**: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

---

**Last Updated**: November 23, 2025  
**Terraform Version**: >= 1.5.0  
**Azure Provider**: ~> 4.0  
