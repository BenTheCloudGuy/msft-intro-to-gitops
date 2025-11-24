# VM Module Example - Directory Structure

## 📁 Complete File Tree

```
vm-module-example/
│
├── 📄 vm.tf                           # ORIGINAL monolithic file (BEFORE conversion)
│                                      # Contains: provider + backend + data + resources (all mixed)
│                                      # 🎓 Shows the ANTI-PATTERN we're fixing
│
├── 📖 VM-MODULE-NOTES.md             # Comprehensive teaching guide
│                                      # Explains: WHERE each file belongs and WHY
│                                      # Contains: Design decisions, common mistakes, scenarios
│
├── 🚀 QUICKSTART.md                  # 5-minute deployment guide
│                                      # Contains: Prerequisites, setup steps, customization guide
│
├── 📋 STRUCTURE.md                   # This file - visual directory map
│
├── 🔒 .gitignore                     # Git ignore rules
│                                      # Excludes: *.tfstate, *.tfvars, .terraform/, secrets
│
├── 📦 modules/                       # ═══ REUSABLE MODULE CODE ═══
│   │                                  # 🎓 Module = Blueprint/Template
│   │                                  # Defines WHAT to create, not WHERE
│   │
│   └── azure-windows-vm/             # Windows VM module
│       │
│       ├── 📘 README.md              # Module documentation
│       │                              # Contains: Usage examples, design rationale
│       │                              # Sections: Overview, Usage, Variables, Outputs, Examples
│       │                              # Lines: ~580
│       │
│       ├── 🏗️ main.tf                # Resource definitions
│       │                              # Contains: NIC, Windows VM, managed disk resources
│       │                              # 🎓 Core module functionality
│       │                              # Lines: ~180
│       │                              # Teaching points: Resource composition, dependencies
│       │
│       ├── 📥 variables.tf           # Input variables (MODULE API)
│       │                              # Contains: Variable declarations (NO VALUES!)
│       │                              # 🎓 Defines module's interface/contract
│       │                              # Lines: ~320
│       │                              # Variables: vm_name, location, subnet_id, vm_size, etc.
│       │                              # All have: description, type, validation, defaults
│       │
│       ├── 📤 outputs.tf             # Output values
│       │                              # Contains: VM info, network info, storage info
│       │                              # 🎓 Exposes data for module composition
│       │                              # Lines: ~130
│       │                              # Outputs: vm_id, vm_name, private_ip, etc.
│       │
│       ├── 🔧 locals.tf              # Computed local values
│       │                              # Contains: Naming convention logic
│       │                              # 🎓 DRY principle - calculate once, use many times
│       │                              # Lines: ~30
│       │                              # Locals: vm_name_with_env, common_tags_merged
│       │
│       └── 📌 versions.tf            # Terraform/provider version constraints
│                                      # Contains: required_version, required_providers
│                                      # 🎓 Documents module requirements
│                                      # Lines: ~50
│                                      # Versions: Terraform >= 1.5.0, azurerm ~> 4.0
│
└── 🌍 environments/                  # ═══ ENVIRONMENT-SPECIFIC CONFIG ═══
    │                                  # 🎓 Root = Orchestra Conductor
    │                                  # Defines WHERE to create, not WHAT
    │
    └── dev/                          # Development environment
        │                              # 🎓 Each environment is independent
        │                              # Separate: state, provider, variables
        │
        ├── 💾 backend.tf             # ⭐ State storage configuration
        │                              # Contains: Azure Storage backend config
        │                              # 🎓 WHERE state is stored
        │                              # Lines: ~60
        │                              # ❌ NEVER in modules (module = reusable, state = per-environment)
        │                              # Teaching: OIDC vs access keys, state organization
        │
        ├── 🔌 provider.tf            # ⭐ Azure provider configuration
        │                              # Contains: Provider block, features, subscription targeting
        │                              # 🎓 WHERE resources are created (subscription/tenant)
        │                              # Lines: ~100
        │                              # ❌ NEVER in modules (modules inherit from root)
        │                              # Teaching: Provider features, authentication methods
        │
        ├── 🔍 data.tf                # ⭐ Data sources (existing resources)
        │                              # Contains: VNet, subnet, Key Vault queries
        │                              # 🎓 Discover existing infrastructure
        │                              # Lines: ~110
        │                              # ❌ Usually NOT in modules (environment-specific)
        │                              # Teaching: Root discovers, module receives IDs
        │
        ├── 🏗️ main.tf                # Module calls & resource composition
        │                              # Contains: Module instantiation, root-level resources
        │                              # 🎓 Orchestrates modules to build complete environment
        │                              # Lines: ~240
        │                              # Examples: 4 individual VMs + for_each pattern
        │                              # Teaching: Module composition, for_each loops
        │
        ├── 📥 variables.tf           # Environment-level variables
        │                              # Contains: Environment-specific variable declarations
        │                              # 🎓 Inputs to THIS environment
        │                              # Lines: ~70
        │                              # Variables: environment, location, project
        │                              # Different from module variables (higher level)
        │
        ├── 📤 outputs.tf             # Environment-level outputs
        │                              # Contains: Aggregated module outputs
        │                              # 🎓 Expose environment data for consumption
        │                              # Lines: ~150
        │                              # Outputs: all_vm_ids, vm_summary, network_summary
        │                              # Includes: Human-readable formatted summaries
        │
        └── 🔐 terraform.tfvars       # ⚠️ Variable values (SENSITIVE!)
                                       # Contains: Actual values for variables
                                       # 🎓 Data for THIS environment
                                       # Lines: ~70
                                       # Values: environment="dev", location="eastus", etc.
                                       # ❌ NEVER commit to Git! (in .gitignore)
                                       # ❌ NEVER in modules (modules don't have values)
                                       # Teaching: Security, secret management
```

---

## 🎯 File Placement Decision Tree

```
┌─────────────────────────────────────────┐
│ Where should this file go?             │
└─────────────────────────────────────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │ Is this a resource    │
        │ definition?           │
        └───────────────────────┘
          │                  │
         YES                NO
          │                  │
          ▼                  ▼
    ┌──────────┐      ┌─────────────┐
    │ Module   │      │ Continue... │
    │ main.tf  │      └─────────────┘
    └──────────┘              │
                              ▼
                  ┌────────────────────────┐
                  │ Is this a variable     │
                  │ declaration?           │
                  └────────────────────────┘
                    │                  │
                   YES                NO
                    │                  │
                    ▼                  ▼
            ┌─────────────┐    ┌──────────────┐
            │ Does it      │    │ Continue...  │
            │ define       │    └──────────────┘
            │ module API?  │            │
            └─────────────┘            ▼
              │        │         ┌───────────────┐
             YES      NO         │ Is this an    │
              │        │         │ output value? │
              ▼        ▼         └───────────────┘
        ┌─────────┐ ┌─────────┐   │          │
        │ Module  │ │ Root    │  YES        NO
        │ vars.tf │ │ vars.tf │   │          │
        └─────────┘ └─────────┘   ▼          ▼
                            ┌─────────┐ ┌────────────┐
                            │ Module  │ │ Continue...│
                            │ or Root │ └────────────┘
                            │outputs  │      │
                            └─────────┘      ▼
                                      ┌──────────────┐
                                      │ Special      │
                                      │ Files:       │
                                      └──────────────┘
                                            │
                    ┌───────────────────────┼────────────────────┐
                    │                       │                    │
                    ▼                       ▼                    ▼
            ┌───────────────┐     ┌────────────────┐   ┌──────────────┐
            │ backend.tf    │     │ provider.tf    │   │ data.tf      │
            │ ❌ NEVER in   │     │ ❌ NEVER in    │   │ ❌ Usually   │
            │ modules       │     │ modules        │   │ NOT in       │
            │ ✅ ROOT only  │     │ ✅ ROOT only   │   │ modules      │
            └───────────────┘     └────────────────┘   └──────────────┘
```

---

## 📊 File Responsibility Matrix

| File Type | Module | Root | Contains | Purpose |
|-----------|--------|------|----------|---------|
| **main.tf** | ✅ | ✅ | Resources (module)<br>Module calls (root) | Core functionality |
| **variables.tf** | ✅ | ✅ | Variable declarations | Define inputs |
| **outputs.tf** | ✅ | ✅ | Output declarations | Expose data |
| **locals.tf** | ✅ | ✅ | Computed values | DRY principle |
| **versions.tf** | ✅ | ❌ | Version constraints | Document requirements |
| **README.md** | ✅ | ❌ | Documentation | Self-documenting code |
| **backend.tf** | ❌ | ✅ | State config | State storage |
| **provider.tf** | ❌ | ✅ | Provider config | Runtime configuration |
| **data.tf** | ❌ | ✅ | Data sources | Query existing resources |
| **terraform.tfvars** | ❌ | ✅ | Variable values | Environment data |

---

## 🎓 Module vs Root Comparison

### Module (Reusable Blueprint)

```
modules/azure-windows-vm/
├── main.tf          # "Create a Windows VM with these characteristics"
├── variables.tf     # "Here's what you can customize"
├── outputs.tf       # "Here's what I'll tell you after creation"
├── versions.tf      # "I require Terraform 1.5+ and azurerm 4.0+"
├── locals.tf        # "I calculate some values internally"
└── README.md        # "Here's how to use me"

🎓 Analogy: Recipe card
   - Ingredients list (variables)
   - Instructions (main.tf)
   - What you'll have when done (outputs)
   - Required tools (versions)
```

### Root (Environment Recipe)

```
environments/dev/
├── backend.tf       # "Store my state in this Azure Storage account"
├── provider.tf      # "Create resources in this subscription"
├── data.tf          # "Find these existing resources for me"
├── main.tf          # "Use the VM recipe 4 times with these variations"
├── variables.tf     # "My environment needs these inputs"
├── outputs.tf       # "Show me summary of everything created"
└── terraform.tfvars # "Here are the actual values to use"

🎓 Analogy: Meal plan for the week
   - Uses recipe cards (modules)
   - Customizes each meal (module calls)
   - Shops for existing ingredients (data sources)
   - Stores results (backend)
```

---

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                   TERRAFORM WORKFLOW                        │
└─────────────────────────────────────────────────────────────┘

1️⃣ INIT: terraform init
   ├── backend.tf     → Connects to state storage
   ├── provider.tf    → Downloads Azure provider
   └── versions.tf    → Validates version requirements

2️⃣ PLAN: terraform plan
   │
   ├── data.tf        → Queries existing Azure resources
   │   ├── VNet ID
   │   ├── Subnet ID
   │   └── Key Vault secret
   │
   ├── terraform.tfvars → Loads variable values
   │   ├── environment = "dev"
   │   ├── location = "eastus"
   │   └── project = "myproject"
   │
   ├── variables.tf   → Receives values
   │
   ├── main.tf        → Calls modules
   │   │
   │   └── module "web_vm" {
   │         source = "../../modules/azure-windows-vm"
   │         │
   │         ├── Passes: subnet_id (from data.tf)
   │         ├── Passes: vm_name = "dev-web-01"
   │         ├── Passes: admin_password (from Key Vault)
   │         │
   │         └──► Module processes inputs
   │              ├── variables.tf validates inputs
   │              ├── locals.tf computes values
   │              ├── main.tf defines resources
   │              └── outputs.tf returns results
   │
   └── outputs.tf     → Aggregates module outputs

3️⃣ APPLY: terraform apply
   ├── Creates resources in Azure
   ├── Stores state in backend
   └── Displays outputs

┌─────────────────────────────────────────────────────────────┐
│                    DATA FLOW                                │
└─────────────────────────────────────────────────────────────┘

terraform.tfvars → variables.tf → main.tf → module inputs
                                      │
                                      ▼
                           ┌──────────────────┐
                           │ Module Logic     │
                           │ - variables.tf   │
                           │ - locals.tf      │
                           │ - main.tf        │
                           └──────────────────┘
                                      │
                                      ▼
                           module outputs → outputs.tf
                                      │
                                      ▼
                              User sees results
```

---

## 🎯 Quick Reference: "Where Does X Go?"

| Element | Module | Root | Reason |
|---------|--------|------|--------|
| `resource "azurerm_windows_virtual_machine"` | ✅ | ❌ | Defines WHAT to create |
| `variable "vm_name"` | ✅ | ❌ | Module's API |
| `variable "environment"` | ❌ | ✅ | Environment-level input |
| `output "vm_id"` | ✅ | ❌ | Module's return value |
| `output "all_vm_ids"` | ❌ | ✅ | Aggregated environment output |
| `locals { vm_name_computed = ... }` | ✅ | ✅ | Computed values (both levels) |
| `backend "azurerm"` | ❌ | ✅ | State per environment |
| `provider "azurerm"` | ❌ | ✅ | Runtime config |
| `data "azurerm_subnet"` | ❌ | ✅ | Environment-specific query |
| `environment = "dev"` | ❌ | ✅ | Actual value (.tfvars) |
| `versions.tf` | ✅ | ❌ | Module requirements |
| `README.md` | ✅ | ❌ | Module documentation |

---

## 📐 Sizing Reference

### Lines of Code

| File | Lines | Purpose |
|------|-------|---------|
| **Module Files** |
| modules/.../README.md | ~580 | Documentation |
| modules/.../main.tf | ~180 | Resource definitions |
| modules/.../variables.tf | ~320 | Input variables |
| modules/.../outputs.tf | ~130 | Output values |
| modules/.../versions.tf | ~50 | Version constraints |
| modules/.../locals.tf | ~30 | Local values |
| **Root Files** |
| environments/dev/main.tf | ~240 | Module calls |
| environments/dev/outputs.tf | ~150 | Environment outputs |
| environments/dev/data.tf | ~110 | Data sources |
| environments/dev/provider.tf | ~100 | Provider config |
| environments/dev/variables.tf | ~70 | Environment variables |
| environments/dev/terraform.tfvars | ~70 | Variable values |
| environments/dev/backend.tf | ~60 | State config |
| **Original** |
| vm.tf | ~100 | Monolithic (anti-pattern) |

### Total Project Size
- **Module code**: ~1,290 lines
- **Root config**: ~800 lines
- **Documentation**: ~580 lines (README) + ~2,000 lines (teaching notes)
- **Original**: ~100 lines (but not reusable or maintainable)

**🎓 Teaching Point**: "Yes, proper structure adds files and lines. But it also adds:
- Reusability (one module → many environments)
- Maintainability (clear separation of concerns)
- Testability (module can be tested independently)
- Documentation (self-explanatory structure)
- Security (secrets separated, state isolated)"

---

## 🚀 Deployment Flow

```
┌──────────────┐
│ Developer    │
│ Workstation  │
└──────────────┘
      │
      │ 1. cd environments/dev
      │ 2. terraform init
      │
      ▼
┌──────────────────────────┐
│ Azure Storage            │
│ (State Backend)          │
│ - tfstate file stored    │
│ - Locking enabled        │
└──────────────────────────┘
      ▲
      │ 3. terraform plan
      │ 4. terraform apply
      ▼
┌──────────────────────────┐
│ Azure Subscription       │
│ - Resource Groups        │
│ - VMs created            │
│ - NICs attached          │
│ - Disks provisioned      │
└──────────────────────────┘
```

---

## 📚 Related Documentation

- **Deployment Guide**: `QUICKSTART.md`
- **Teaching Notes**: `VM-MODULE-NOTES.md`
- **Module Docs**: `modules/azure-windows-vm/README.md`
- **Best Practices**: `../../LAB3-TF-MODULE.md`

---

**Last Updated**: November 23, 2025  
**Purpose**: Visual guide to module structure and file placement  
**Audience**: Students learning Terraform module best practices  
