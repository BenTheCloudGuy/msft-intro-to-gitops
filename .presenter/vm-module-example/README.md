# VM Module Example - Complete Package

## 🎯 What This Is

A **comprehensive teaching example** demonstrating how to convert a monolithic Terraform configuration into a properly structured, reusable module following Azure and Terraform best practices.

---

## 📖 Documentation Index

### 🚀 **Start Here**

1. **[QUICKSTART.md](./QUICKSTART.md)** - 5-minute deployment guide
   - Prerequisites checklist
   - Customization instructions (**IMPORTANT**: Example won't work without customization)
   - Step-by-step deployment
   - Learning exercises
   - Troubleshooting guide

### 📚 **Deep Dive**

2. **[VM-MODULE-NOTES.md](./VM-MODULE-NOTES.md)** - Comprehensive teaching guide (4,000+ lines)
   - **File Placement Rules**: Where backend.tf, provider.tf, data.tf belong and WHY
   - **Design Decisions**: Why each option was chosen (security, performance, cost)
   - **Teaching Scenarios**: Common questions with detailed answers
   - **Conversion Process**: From monolithic to modular step-by-step
   - **Common Mistakes**: What NOT to do and how to fix
   - **Student Checklist**: Verify you've done everything correctly

3. **[STRUCTURE.md](./STRUCTURE.md)** - Visual directory structure guide
   - Complete file tree with annotations
   - File placement decision tree
   - Responsibility matrix (module vs root)
   - Data flow diagrams
   - Quick reference tables
   - Lines of code metrics

4. **[modules/azure-windows-vm/README.md](./modules/azure-windows-vm/README.md)** - Module documentation
   - Usage examples
   - Variable reference
   - Output reference
   - Design rationale
   - Troubleshooting

---

## 📁 Quick Navigation

### Original File (BEFORE)
```
vm.tf                    # Monolithic anti-pattern (100 lines)
                        # Shows what NOT to do
```

### Module Files (Reusable Code)
```
modules/azure-windows-vm/
├── README.md            # Module documentation (580 lines)
├── main.tf              # Resource definitions (180 lines)
├── variables.tf         # Input variables (320 lines)
├── outputs.tf           # Output values (130 lines)
├── versions.tf          # Version constraints (50 lines)
└── locals.tf            # Computed values (30 lines)
```

### Root Configuration (Environment-Specific)
```
environments/dev/
├── backend.tf           # ⭐ State storage (60 lines)
├── provider.tf          # ⭐ Azure provider (100 lines)
├── data.tf              # ⭐ Existing resources (110 lines)
├── main.tf              # Module calls (240 lines)
├── variables.tf         # Environment variables (70 lines)
├── outputs.tf           # Aggregated outputs (150 lines)
└── terraform.tfvars     # Variable values (70 lines)
```

---

## 🎓 Key Learning Objectives

### Primary Concepts

✅ **Module vs Root Separation**
- Modules contain reusable code (templates)
- Root contains environment configuration (data)
- Clear separation of concerns

✅ **File Placement Rules**
- `backend.tf` → Root only (state per environment)
- `provider.tf` → Root only (modules inherit)
- `data.tf` → Root only (environment-specific queries)
- `terraform.tfvars` → Root only (never commit!)

✅ **Best Practices Explained**
- Why no public IP by default (security)
- Why accelerated networking enabled (performance)
- Why Premium_LRS for OS disk (SLA + performance)
- Why manual patching default (control)
- Why separate NIC resource (flexibility)

---

## 🚀 Quick Start (3 Steps)

### 1. Read Prerequisites
```powershell
# Open quickstart guide
code QUICKSTART.md

# Focus on "Before You Deploy" section
# You MUST customize: backend.tf, provider.tf, data.tf, terraform.tfvars
```

### 2. Deploy Example
```powershell
cd environments/dev
terraform init
terraform plan
terraform apply
```

### 3. Learn from Code
```powershell
# Read teaching comments in files
code ../../modules/azure-windows-vm/main.tf
code main.tf
code ../../VM-MODULE-NOTES.md
```

---

## 📊 Project Metrics

| Metric | Value | Purpose |
|--------|-------|---------|
| **Total Files** | 20 | Complete working example |
| **Module Files** | 6 | Reusable VM module |
| **Root Files** | 7 | Dev environment config |
| **Documentation Files** | 5 | Teaching guides |
| **Total Lines** | ~7,000+ | Comprehensive with teaching comments |
| **Teaching Points** | 100+ | 🎓 annotations throughout |
| **Code Examples** | 50+ | Working code snippets |
| **Decision Rationales** | 20+ | Why each choice was made |

---

## 🎯 Use Cases

### For Students
- **Learn**: Module structure and best practices
- **Practice**: Converting monolithic → modular
- **Understand**: File placement rules (WHERE and WHY)
- **Reference**: Design decision rationales

### For Instructors
- **Teach**: Terraform modules with real example
- **Demonstrate**: Proper file organization
- **Discuss**: Security, performance, cost tradeoffs
- **Assess**: Student understanding via exercises

### For Teams
- **Template**: Starting point for your own modules
- **Standard**: Consistent structure across projects
- **Documentation**: Self-documenting code example
- **Reference**: Quick lookup for file placement

---

## 🔑 Key Files for Different Goals

### "I want to deploy this quickly"
→ **[QUICKSTART.md](./QUICKSTART.md)**

### "I want to understand file placement"
→ **[VM-MODULE-NOTES.md](./VM-MODULE-NOTES.md)** (File Placement Rules section)

### "I want to see the directory structure"
→ **[STRUCTURE.md](./STRUCTURE.md)**

### "I want to use the module"
→ **[modules/azure-windows-vm/README.md](./modules/azure-windows-vm/README.md)**

### "I want to see the original problem"
→ **[vm.tf](./vm.tf)** (the monolithic BEFORE file)

### "I want to understand design decisions"
→ **[VM-MODULE-NOTES.md](./VM-MODULE-NOTES.md)** (Key Design Decisions section)

---

## ⚠️ Important Notes

### Before Deploying

1. **Customization Required** - This example will NOT work out-of-the-box
   - Update `backend.tf` with your state storage
   - Update `provider.tf` with your subscription
   - Update `data.tf` with your existing resources
   - Update `terraform.tfvars` with your values

2. **Create Prerequisites**
   - Azure Storage account for state
   - Virtual Network with subnets
   - Key Vault with admin password secret
   - Appropriate Azure permissions

3. **Security Warnings**
   - Never commit `terraform.tfvars` to Git (in .gitignore)
   - Use Key Vault for secrets (example does this)
   - Consider Azure Bastion instead of public IPs
   - Review RBAC permissions before deploying

### After Deploying

1. **Cost Awareness**
   - This creates 4 VMs by default (~$400-600/month)
   - Remember to `terraform destroy` when done
   - Adjust VM sizes in `main.tf` for lower costs

2. **Learning Path**
   - Deploy to understand structure
   - Read teaching comments in code
   - Try the learning exercises
   - Customize for your needs

---

## 🏗️ What Gets Created

### Default Deployment (environments/dev/)

```
Azure Resources:
├── Resource Group
│   └── dev-vm-rg
│
├── 4 Virtual Machines
│   ├── dev-web-01 (Standard_D2s_v5)
│   ├── dev-app-01 (Standard_D4s_v5)
│   ├── dev-sql-01 (Standard_E4s_v5)
│   └── dev-util-01 (Standard_B2s)
│
├── 4 Network Interfaces
│   ├── dev-web-01-nic
│   ├── dev-app-01-nic
│   ├── dev-sql-01-nic
│   └── dev-util-01-nic
│
├── 2 Managed Disks (data disks)
│   ├── dev-app-01-data-disk
│   └── dev-sql-01-data-disk
│
└── 4 OS Disks (auto-created)
```

**Estimated Monthly Cost**: ~$400-600 USD (varies by region)

---

## 📚 Additional Resources

### Terraform Documentation
- [Modules Overview](https://developer.hashicorp.com/terraform/language/modules)
- [Module Development](https://developer.hashicorp.com/terraform/language/modules/develop)
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

### Azure Documentation
- [Azure Virtual Machines](https://learn.microsoft.com/azure/virtual-machines/)
- [VM Sizes](https://learn.microsoft.com/azure/virtual-machines/sizes)
- [Managed Disks](https://learn.microsoft.com/azure/virtual-machines/managed-disks-overview)

### Best Practices
- [LAB3-TF-MODULE.md](../../LAB3-TF-MODULE.md) - Complete module guide
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices)
- [Azure Well-Architected](https://learn.microsoft.com/azure/architecture/framework/)

---

## ❓ FAQ

**Q: Can I use this in production?**
A: This is a teaching example. For production:
- Add availability zones
- Implement backup policies
- Add monitoring/alerts
- Use Azure Policy
- Implement proper RBAC
- Add disaster recovery

**Q: Why so many files?**
A: Separation of concerns:
- Makes code reusable
- Easier to maintain
- Clearer responsibilities
- Better for teams
- Industry standard

**Q: Can I modify the module?**
A: Absolutely! Common modifications:
- Add public IP support
- Add availability zones
- Add backup configuration
- Add monitoring
- Create Linux version

**Q: How do I create staging/prod?**
A: Copy `environments/dev/` to `environments/staging/`:
- Update `backend.tf` (different state file)
- Update `provider.tf` (different subscription maybe)
- Update `data.tf` (staging VNet/subnets)
- Update `terraform.tfvars` (staging values)

**Q: Where do I start learning?**
A: Recommended path:
1. Read QUICKSTART.md (understand what this is)
2. Deploy the example (hands-on)
3. Read VM-MODULE-NOTES.md (deep understanding)
4. Read STRUCTURE.md (visual reference)
5. Read module README.md (how to use)
6. Try learning exercises (practice)

---

## 🆘 Getting Help

### Common Issues

**"Backend initialization failed"**
→ Create Azure Storage account first (see QUICKSTART.md)

**"Data source not found"**
→ Create VNet/subnet or update data.tf with existing names

**"Insufficient quota"**
→ Request quota increase or use smaller VM sizes

**"Access denied to Key Vault"**
→ Grant yourself RBAC permissions (Key Vault Secrets User)

### Troubleshooting Steps

1. Check prerequisites are created
2. Verify Azure CLI authentication (`az account show`)
3. Validate Terraform files (`terraform validate`)
4. Review plan carefully (`terraform plan`)
5. Check Azure Portal for existing resources
6. Review [QUICKSTART.md](./QUICKSTART.md) troubleshooting section

---

## 🎓 Teaching Tips (For Instructors)

### Recommended Flow

1. **Show Original** (`vm.tf`)
   - "This works, but..."
   - Point out anti-patterns
   - Discuss reusability issues

2. **Explain Structure** (STRUCTURE.md)
   - Module vs root
   - File responsibilities
   - Visual decision tree

3. **Deep Dive** (VM-MODULE-NOTES.md)
   - File placement rules
   - Design decisions
   - Common mistakes

4. **Hands-On** (QUICKSTART.md)
   - Students deploy
   - Modify variables
   - Add new VMs

5. **Exercises**
   - Create staging environment
   - Add public IP support
   - Implement availability zones
   - Write tests

### Discussion Questions

- "Why can't provider.tf be in the module?"
- "What happens if we put data.tf in the module?"
- "Where should backend.tf go and why?"
- "How would you structure multi-region deployment?"
- "What's the benefit of separate NIC resources?"

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Nov 23, 2025 | Initial complete example |
| | | - 6 module files |
| | | - 7 root files |
| | | - 5 documentation files |
| | | - 100+ teaching points |

---

## 📄 License & Attribution

This is a teaching example created for educational purposes.

- **Purpose**: Demonstrate Terraform module best practices
- **Audience**: Students, teams, developers learning Terraform
- **Usage**: Free to use, modify, extend for learning
- **Attribution**: Please reference when sharing

---

## 🎯 Learning Outcomes

After completing this example, you should understand:

✅ Difference between modules and root configuration  
✅ Where backend.tf, provider.tf, data.tf belong  
✅ How to structure reusable Terraform modules  
✅ Why separation of concerns matters  
✅ How to pass data between root and modules  
✅ Best practices for Azure VM deployment  
✅ Design tradeoffs (security vs convenience)  
✅ How to manage multiple environments  

---

**Ready to Start?** → Open **[QUICKSTART.md](./QUICKSTART.md)**

**Want Deep Dive?** → Open **[VM-MODULE-NOTES.md](./VM-MODULE-NOTES.md)**

**Need Visual Guide?** → Open **[STRUCTURE.md](./STRUCTURE.md)**

---

**Last Updated**: November 23, 2025  
**Total Package Size**: ~7,000+ lines of code and documentation  
**Teaching Points**: 100+ detailed explanations  
**Example Scenarios**: 20+ common questions answered  
