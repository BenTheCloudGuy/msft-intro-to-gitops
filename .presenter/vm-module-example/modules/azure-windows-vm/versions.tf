# modules/azure-windows-vm/versions.tf
#
# 🎓 TEACHING POINT: Version constraints ensure compatibility
# - Prevents breaking changes from provider updates
# - Documents minimum required versions
# - Essential for reproducible deployments

# 🎓 WHY IN MODULE: Each module declares its own requirements
# - Root config can use same or newer versions
# - Prevents version conflicts
# - Makes module requirements explicit

terraform {
  # 🎓 TEACHING POINT: Terraform version constraint
  # - >= 1.5.0 enables latest language features
  # - Terraform 1.5+ has improved test framework
  # - Terraform 1.5+ has better error messages
  # - Use ~> 1.5 to allow minor version updates but prevent major updates
  required_version = ">= 1.5.0"
  
  required_providers {
    # 🎓 TEACHING POINT: AzureRM provider version
    # - ~> 4.0 means >= 4.0.0 and < 5.0.0
    # - Allows minor/patch updates (4.1, 4.2, etc.)
    # - Prevents major version jumps that could break code
    # - Always check changelog before updating: https://github.com/hashicorp/terraform-provider-azurerm/blob/main/CHANGELOG.md
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    
    # 🎓 TEACHING POINT: Why specify source?
    # - Ensures consistent provider across environments
    # - Prevents using wrong provider (community vs official)
    # - Required for Terraform Registry modules
  }
}

# 🎓 TEACHING POINT: What NOT to include in versions.tf
# ❌ provider "azurerm" { } blocks - Those belong in ROOT config
# ❌ backend "azurerm" { } blocks - Those belong in ROOT backend.tf
# ❌ terraform { backend {} } - State backend is root-level concern

# 🎓 Version Constraint Syntax:
# >= 1.0       Allow any version >= 1.0
# ~> 1.0       Allow >= 1.0 and < 2.0 (recommended)
# ~> 1.2.0     Allow >= 1.2.0 and < 1.3.0
# >= 1.0, < 2.0  Explicit range
# = 1.0        Exact version only (avoid this)

# 🎓 Best Practices:
# - Use ~> for providers (allows patch/minor updates)
# - Use >= for Terraform (allows newer client versions)
# - Test updates in dev before updating prod
# - Pin exact versions in production for critical systems
# - Document any specific version requirements in README
