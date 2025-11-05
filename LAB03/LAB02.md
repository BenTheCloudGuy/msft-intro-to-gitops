# Lab Guide

This step in the lab focuses on setting up the foundational Terraform configuration files and defining the necessary variables for deploying infrastructure. By creating and populating files such as lab.tfvars, users provide input values for resource naming, tagging, and application server configurations. These configurations ensure modularity, scalability, and flexibility in managing infrastructure as code. After this we can

## Setting Terraform Files

This step in the lab focuses on setting up the foundational files for Terraform configuration. Navigate to the Terraform directory and create the necessary files (data.tf, locals.tf, main.tf, outputs.tf, provider.tf, and variables.tf) to structure the infrastructure as code. These files serve specific purposes, such as defining data sources, local values, providers, variables, and outputs, ensuring a modular and organized approach to managing infrastructure.

1. Set current directory to ``/workspaces/lab-api/infra/terraform``:

   ```sh
   cd /workspaces/lab-api/infra/terraform
   ```
2. Create Terraform file:

   ```sh
   touch data.tf locals.tf main.tf outputs.tf provider.tf variables.tf lab.tfvars
   ```

   The Current Repo Layout should look like this:

   ```sh
   .
   ├── Dockerfile
   ├── .gitignore
   ├── infra
   │   ├── ansible
   │   └── terraform
   │       ├── data.tf
   │       ├── locals.tf
   │       ├── main.tf
   │       ├── outputs.tf
   │       ├── provider.tf
   │       └── variables.tf
   ├── README.md
   └── src
       ├── package.json
       └── server.js
   ```

## Add Content to the files

This step in the lab will guide you in creating and understanding the key Terraform configuration files required to deploy the WebAPI Demo App infrastructure. Each file serves a specific purpose in defining and managing the infrastructure. For example, ``data.tf`` retrieves existing Azure resources and user credentials, while ``provider.tf`` specifies the providers and backend configuration for Terraform. By carefully following these steps, you will gain a deeper understanding of how Terraform organizes and executes infrastructure as code, enabling them to build modular, scalable, and maintainable configurations.

> **NOTE**
> Take your time and read through what you are copying over and try and understand what each configuration item is doing.

---

### provider.tf

This step introduces the ``provider.tf`` file, which is essential for configuring the providers and backend that Terraform will use to manage infrastructure. The file specifies the required providers, such as azapi, azurerm, and random, along with their respective versions to ensure compatibility and functionality for managing Azure resources and generating random values.

Additionally, the backend **"azurerm"** block configures Terraform to store its state file in an Azure Storage Account you setup using the AzCLI in the previous Lab, allowing for collaboration among team members and maintaining state consistency across multiple users. When testing locally it is okay to keep the statefile local, but in all other environments, it should be remotely stored and secured.

> **NOTE**
> The Terraform State file needs to be secured as it contains sensative data used in the creation of the environment. Treat this like you would your own sensative data and limit who has access to read the file from the remote state.

Copy the following into your ``provider.tf``.

```hcl
terraform {
    required_version = "~> 1.11.0"

    required_providers {
        terraform {
        required_version = "~> 1.11.0"

        required_providers {
        azapi = {
            source  = "azure/azapi"
            version = "~>2.3.0"
        }
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~>4.25.0"
        }
        random = {
            source  = "hashicorp/random"
            version = "~>3.7.0"
        }
    }

    backend "azurerm" {
        resource_group_name  = "<your-resource-group>"
        storage_account_name = "<your-storage-account>"
        container_name       = "tfstate"
        key                  = "gitops.tfstate"
        tenant_id            = "<your-tenant-id>"
        use_azuread_auth     = true
    }
}

provider "azurerm" {
    features {}
    subscription_id = "<your-subscription-id>"
}
```

> **NOTE**
> In this step, the ``provider.tf`` file specifies the required providers (azapi, azurerm, and random) along with their versions, ensuring compatibility and functionality for managing Azure resources and generating random values. Additionally, the backend "azurerm" block configures Terraform to store its state file in an Azure Storage Account, enabling collaboration and ensuring state consistency across multiple users.

> **COPILOT**
> Notice in the linter is alerting us that terraform{} block isn't expected in the code there. Lets ask CoPilot to help us fix this! simply open up co-pilot and type 'how do I fix this?' and review proposed changes?

```hcl
terraform {
    required_version = "~> 1.11.0"

    required_providers {
        azapi = {
            source  = "azure/azapi"
            version = "~>2.3.0"
        }
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~>4.25.0"
        }
        random = {
            source  = "hashicorp/random"
            version = "~>3.7.0"
        }
    }

    backend "azurerm" {
        resource_group_name  = "rg_bmmsidvgl"
        storage_account_name = "strartifactsbmmsidvgl"
        container_name       = "tfstate"
        key                  = "gitops.tfstate"
        tenant_id            = "477bacc4-4ada-4431-940b-b91cf6cb3fd4"
        use_azuread_auth     = true
    }
}

provider "azurerm" {
    features {}
    subscription_id = "f5cc0b2b-b4ba-437f-b770-863a80cf9da0"
}
```

---

### data.tf

This step focuses on updating the ``data.tf`` file to define two essential data sources in Terraform. The first data source, **azurerm_client_config**, retrieves the current user's Azure credentials, ensuring that Terraform can authenticate and interact with Azure resources. The second data source, **azurerm_resource_group**, references an existing Azure resource group that you created using the AzCLI, allowing Terraform to manage resources within it.

> **NOTE**
> Data Import is something that you will commonly have to do when working with various existing infrastructure that is managed else where. Typlically you would create the ResourceGroup(s) as part of the Platform you are deploying vs referencing an existing one. It should offer something like this in return:

Copy the following into your ``data.tf`` file.

```hcl
# Import Current User Credentials
data "azurerm_client_config" "current" {
    provider = azurerm
}

# Import Existing Resource Group created using the Azure CLI
data "azurerm_resource_group" "rg" {
    name = "rg-${var.initials}${var.random_string}" 
}
```

---

### locals.tf

The locals.tf file in Terraform is used to define local values, which are named expressions that simplify and reuse complex or repetitive values in your configuration. In this step, the locals.tf file defines a resourceTags local value that merges predefined tags (var.tags) with a dynamically generated DeploymentUTC tag.

Copy the following into your ``locals.tf``.

```hcl
locals {
    ## Add Current Date/Time tag
    resourceTags = merge(
        var.tags,
        {
            DeploymentUTC = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp()),
        }
    )
}
```

---

### variables.tf

This step introduces the ``variables.tf`` file, which is used to define input variables that make Terraform configurations flexible and reusable. These variables allow users to customize their infrastructure by providing values for specific parameters, such as a random string for resource uniqueness (random_string), user initials for naming conventions (initials), and a map of tags for resource metadata (tags). Additionally, the appServersConfig variable defines an object to configure application servers, including details like the VM name prefix, count, admin username, availability zones, SSH key path, and VM SKU.

> **NOTE**
> You can use the {default = "value"} property if you want to have a default value and not have to pass the variable in at runtime. I typically steer clear of "default" values. Either pass it in as part of the module or use the locals.tf to create the values dynamically to be passed in at runtime.
>
> Another thing that is recommended is keeping the number of variables required to a minimum. Again use dynamic configurations whenever possible.

Copy the following into your ``variables.tf``:

```hcl
variable "random_string" {
    description = "A random string to be appended to the resource group name for uniqueness."
    type        = string
}

variable "initials" {
    description = "The initials to be used for the resource group name."
    type        = string
}

variable "tags" {
    description = "A map of tags to be applied to the resources."
    type        = map(string)
    default     = {}
}

variable "appServersConfig" {
    description = "Configuration for App Servers"
    type = object({
        vmnameprefix  = string
        vmcount       = number
        adminUsername = string
        zones         = list(string)
        key_path      = string
        vm_sku        = string
    })
}
```

---

### lab.tfvars

The lab.tfvars file is used to define input variables for the Terraform configuration. It provides specific values for variables such as naming conventions, tags, and application server configurations.

Copy the following into your ``lab.tfvars``

```hcl
# Lab Configurations
initials      = "<your-initials>"
random_string = "<your-random-string>"

## Tag Vars
tags = {
  "Owner"       = "<your-name>"
  "Environment" = "GitOps Lab"
}

## App Server Confiugurations
appServersConfig = {
    vmnameprefix    = "webapp"
    vmcount         = 2
    adminUsername   = "labAdmin"
    zones           = ["3"]
    key_path        = "/home/vscode/.ssh/ansible.pub"
    vm_sku          = "Standard_D2s_v6"
}
```

---

### outputs.tf

The ``outputs.tf`` file in Terraform is used to define outputs that provide critical information about the infrastructure after it has been provisioned. These outputs make it easier to access and reference key details, such as the resource group name (ResourceGroupName), Azure region (AzureRegion), and the name of the Azure Bastion host (BastionName).

Additionally, it includes outputs for the private IP addresses of the virtual machines (vm_private_ips), the public IP address of the load balancer (lb_public_ip), and the resource IDs of the virtual machines (vm_resourceId). By defining these outputs, users can easily retrieve and use these values in other configurations, scripts, or documentation, streamlining the management and integration of the deployed infrastructure.

> **NOTE**
> A common technique in building out automated pipelines is to leverage the Terraform Outputs to gather information from the deployment for use in other stages of the build.

Copy the following into your ``outputs.tf``:

```hcl
output "ResourceGroupName" {
    value = data.azurerm_resource_group.rg.name
}

output "AzureRegion" {
    value = data.azurerm_resource_group.rg.location
}

output "BastionName" {
    value = module.azure_bastion.name
}

output "vm_private_ips" {
    description = "PrivateIP addresses of the VMs"
    value = [
        for vm in module.webappServers : vm.network_interfaces.nic0.private_ip_address
    ]
}

output "lb_public_ip" {
    value = azurerm_public_ip.webapp_lb_pip.ip_address
}

output "vm_resourceId" {
    value = [
        for vm in module.webappServers : vm.resource_id
    ]
} 
```

---

### main.tf

This step in the lab focuses on building the ``main.tf`` file, which serves as the central configuration file for defining and orchestrating the deployment of infrastructure resources. Users will add modules and resources to create a virtual network, configure a network security group, deploy an Azure Bastion host, set up a load balancer, and provision virtual machines. Each section of the file is modular and reusable, leveraging Terraform modules and resource blocks. Each section is broken down around a common solution or technology.

- The below code blocks demonstrates the use of Azure Verified Modules (AVMs) to import core modules into a Terraform configuration. These modules are pre-built, reusable components designed to simplify and standardize infrastructure deployment on Azure. Here's a breakdown of what each module does and its purpose:

  #### Module "naming"


  ```hcl
  module "naming" {
      source  = "Azure/naming/azurerm"
      version = "~> 0.4"
  }
  ```

  > **NOTE**
  > This module provides a standardized naming convention for Azure resources. It ensures that resource names follow Azure's best practices, such as adhering to length restrictions and avoiding invalid characters.
  > Why Use It: Consistent naming conventions improve resource management, readability, and compliance with organizational policies
  >

  > **INFO**
  > https://registry.terraform.io/modules/Azure/naming/azurerm/latest
  >

  #### Module "Regions

  ```hcl
  module "regions" {
      source                    = "Azure/avm-utl-regions/azurerm"
      version                   = "0.3.0"
      enable_telemetry          = false
      availability_zones_filter = true
  }
  ```

  > **NOTE**Purpose: This module helps manage Azure regions and availability zones. It provides functionality to filter and select regions or zones based on specific criteria.**Why Use It**: Ensures that resources are deployed in regions and zones that meet availability and redundancy requirements.Key Features:
  >
  >> enable_telemetry: Enables telemetry to track usage and improve the module.
  >> availability_zones_filter: Filters regions based on the availability of zones.
  >>
  >

  > **INFO**
  > https://registry.terraform.io/modules/Azure/avm-utl-regions/azurerm/latest
  >

  #### Module 'vm_sku'

  ```hcl
  module "vm_sku" {
  source = "Azure/avm-utl-sku-finder/azapi"

      version       = "0.3.0"
      location      = data.azurerm_resource_group.rg.location
      cache_results = false
      vm_filters    = {
          max_vcpus = 2
      }
  }
  ```

  > **NOTE**
  > Instead of manually searching for and validating VM SKUs, this module automates the process by applying filters and retrieving compatible SKUs for the specified region. It ensures compatiblity by specifying the location, the module ensures that the selected SKU is available in the target Azure region, avoiding deployment errors.
  > The vm_filters parameter allows users to define constraints (e.g., maximum vCPUs), ensuring that the selected SKU meets performance and cost requirements.
  > The module is reusable across different configurations and environments, making it easier to maintain and scale infrastructure deployments.
  >

  > **INFO**
  > https://registry.terraform.io/modules/Azure/avm-utl-sku-finder/azapi/latest
  >
- The Azure/avm-res-network-virtualnetwork/azurerm module is an Azure Verified Module (AVM) used to create and manage a virtual network (VNet) in Azure. This module simplifies the process of defining a VNet and its associated subnets while adhering to Azure best practices.

  #### Module "virtual_network"


  ```hcl
  # Create Virtual Network
  module "virtual_network" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

      address_space       = ["10.0.0.0/24"]
      location            = data.azurerm_resource_group.rg.location
      name                = "vnet-${var.initials}${var.random_string}"
      resource_group_name = data.azurerm_resource_group.rg.name
      tags                = local.resourceTags
      subnets = {
          "subnet1" = {
              name             = "AzureBastionSubnet"
              address_prefixes = ["10.0.0.0/26"]
          }
          "subnet2" = {
              name             = "AppSubnet"
              address_prefixes = ["10.0.0.64/26"]
          }
      }
  }
  ```

  > **NOTE**
  > Automates the creation of a virtual network and its subnets, reducing the complexity of manual configuration. Adheres to Azure's recommended practices for network design, ensuring scalability, security, and performance. Provides a reusable and modular approach to defining VNets, making it easier to integrate with other Terraform configurations.
  >

  > - The ``address_space`` parameter specifies the IP address range for the VNet (10.0.0.0/24 in this case).
  > - The ``location`` parameter ensures the VNet is deployed in the same Azure region as the specified resource group.
  > - The ``tags`` parameter uses local.resourceTags to apply metadata to the VNet and its subnets
  > - The ``subnets`` block allows the creation of multiple subnets within the VNet. Each subnet is defined with a unique name and address prefix:
  >   - ``subnet1`` is reserved for Azure Bastion with the name AzureBastionSubnet and address prefix 10.0.0.0/26.
  >   - ``subnet2`` is for application resources with the name AppSubnet and address prefix 10.0.0.64/26.
  >

  > **INFO**
  > https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest/examples/default
  >
- The ``azurerm_network_security_group`` resource defines a Network Security Group (NSG) named AppSubnetNSG. NSGs are used to control inbound and outbound traffic to Azure resources at the network level.

  The ``azurerm_subnet_network_security_group_association`` resource links the NSG (AppSubnetNSG) to a specific subnet (subnet2) in the virtual network.

  #### Resource "azurerm_network_security_group"


  ```hcl
  # Create a Network Security Group
  resource "azurerm_network_security_group" "app_subnet_nsg" {
      name                = "AppSubnetNSG"
      location            = data.azurerm_resource_group.rg.location
      resource_group_name = data.azurerm_resource_group.rg.name

      # Create HTTP Inbound Rule
      security_rule {
          name                       = "AllowHTTP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "10.0.0.0/24"
      }
      tags = local.resourceTags
  }

  # Associate the NSG with the AppSubnet
  resource "azurerm_subnet_network_security_group_association" "app_subnet_nsg_association" {
      subnet_id                 = module.virtual_network.subnets["subnet2"].resource_id  
      network_security_group_id = azurerm_network_security_group.app_subnet_nsg.id
  }
  ```

  > **NOTE**The NSG is created in the same location and resource group as the existing Azure resources, using ``data.azurerm_resource_group.rg``.location and ``data.azurerm_resource_group.rg.name``.
  > A security rule named AllowHTTP is added to allow inbound HTTP traffic on port 80.
  >
  > - ``priority``: Set to 100, which determines the order of rule evaluation (lower numbers are evaluated first).
  > - ``direction``: Specifies the traffic direction as Inbound.
  > - ``access``: Allows the traffic (Allow).
  > - ``protocol``: Restricts the rule to Tcp traffic.
  > - ``source_port_range``: Allows traffic from any source port (*).
  > - ``destination_port_range``: Restricts traffic to port 80.
  > - ``source_address_prefix``: Allows traffic from any source IP (*).
  > - ``destination_address_prefix``: Restricts traffic to the subnet's address range (10.0.0.0/24).
  >

  > Subnet Association:
  >
  > - ``subnet_id``: References the resource ID of subnet2 from the module.virtual_network output.
  >   ``network_security_group_id``: References the ID of the AppSubnetNSG NSG.
  >

  > **INFO**
  > https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
  >
- The azure_bastion module creates an Azure Bastion Host, a secure and scalable service that provides seamless RDP and SSH connectivity to virtual machines (VMs) in a virtual network without exposing them to the public internet. This module simplifies the deployment of Azure Bastion while adhering to best practices for security and performance.

  #### Module "azure_bastion"


  ```hcl
  # Create Azure Bastion Host
  module "azure_bastion" {
  source = "Azure/avm-res-network-bastionhost/azurerm"

      enable_telemetry    = false
      name                = "bastion_${var.initials}${var.random_string}"
      resource_group_name = data.azurerm_resource_group.rg.name
      location            = data.azurerm_resource_group.rg.location
      copy_paste_enabled  = true
      file_copy_enabled   = true
      sku                 = "Standard"
      ip_connect_enabled     = true
      shareable_link_enabled = true
      tunneling_enabled      = true
      kerberos_enabled       = true
      ip_configuration = {
          name                 = "my-ipconfig"
          subnet_id            = module.virtual_network.subnets["subnet1"].resource_id
          create_public_ip     = true
          public_ip_address_name = "bastionpip-${var.initials}${var.random_string}"
      }
      tags = local.resourceTags
  }
  ```

  > **NOTE**Parameter Breakdown
  > ``source``: Specifies the Azure Verified Module (AVM) for deploying an Azure Bastion Host. Ensures a standardized and reliable deployment.
  > ``enable_telemetry``: Set to false to disable telemetry data collection for the module.``name``: Defines the name of the Bastion Host, dynamically generated using user initials and a random string for uniqueness.``resource_group_name``: Specifies the name of the resource group where the Bastion Host will be deployed, referencing an existing resource group.``location``: Defines the Azure region for deployment, ensuring the Bastion Host is created in the same region as other resources.``copy_paste_enabled``: Enables clipboard functionality for copying and pasting text between the local machine and remote sessions.``file_copy_enabled``: Allows file transfer between the local machine and the connected VMs.``sku``: Specifies the SKU for the Bastion Host. In this case, it is set to Standard, which supports advanced features like tunneling.``ip_connect_enabled``: Enables direct IP-based connectivity to VMs.``shareable_link_enabled``: Allows the generation of shareable links for remote access to VMs.``tunneling_enabled``: Enables tunneling for secure connectivity to VMs. This is what we use to connect securely via SSH to run the Ansible Playbooks.
  > ``kerberos_enabled``: Enables Kerberos authentication for enhanced security.``ip_configuration``: Configures the IP settings for the Bastion Host:
  >
  > - ``name``: Name of the IP configuration.
  > - ``subnet_id``: Associates the Bastion Host with a specific subnet (subnet1) in the virtual network.
  > - ``create_public_ip``: Creates a public IP address for the Bastion Host.
  > - ``public_ip_address_name``: Defines the name of the public IP address, dynamically generated for uniqueness.
  > - ``tags``: Applies metadata to the Bastion Host using local.resourceTags, which typically includes information like environment, owner, or deployment timestamp.
  >

  > **INFO**
  > https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/azurerm/latest?tab=inputs
  >
- This configuration sets up an Azure Load Balancer to distribute incoming traffic across multiple backend virtual machines (VMs) and manage outbound traffic. The load balancer ensures high availability, scalability, and fault tolerance for applications by routing traffic efficiently and monitoring the health of backend instances.

  #### Azure Load-Balancer


  ```hcl
  # Create Azure Public IP for LoadBalancer
  resource "azurerm_public_ip" "webapp_lb_pip" {
      name                = "lbpip${var.initials}${var.random_string}"
      location            = data.azurerm_resource_group.rg.location
      resource_group_name = data.azurerm_resource_group.rg.name
      sku                 = "Standard"
      allocation_method   = "Static"
      tags                = local.resourceTags
  }
  ```

  > **NOTE**
  > ``name``: Dynamically generates a unique name for the public IP using user initials and a random string.
  > ``location``: Specifies the Azure region for the public IP, matching the resource group location.
  > ``resource_group_name``: Associates the public IP with the specified resource group.
  > ``sku``: Sets the SKU to Standard, which supports advanced features like zone redundancy.
  > ``allocation_method``: Configures the IP allocation as Static, ensuring the IP address remains constant.
  > ``tags``: Applies metadata to the public IP for better organization and management.
  >

  > **INFO**
  > https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
  >

  ```hcl
  # Create Azure Load Balancer
  resource "azurerm_lb" "webapp_lb" {
      name                = "lb-${var.initials}${var.random_string}"
      location            = data.azurerm_resource_group.rg.location
      resource_group_name = data.azurerm_resource_group.rg.name
      sku                 = "Standard"

      frontend_ip_configuration {
          name                 = "frontend-${var.initials}${var.random_string}"
          public_ip_address_id = azurerm_public_ip.webapp_lb_pip.id
      }
  }
  ```

  > **NOTE**``name``: Dynamically generates a unique name for the load balancer.``location``: Specifies the Azure region for the load balancer.``resource_group_name``: Associates the load balancer with the specified resource group.``sku``: Sets the SKU to Standard, enabling advanced features like multiple frontend IPs and zone redundancy.``frontend_ip_configuration``:
  >
  > - ``name``: Defines a unique name for the frontend IP configuration.
  > - ``public_ip_address_id``: Links the frontend IP configuration to the public IP created earlier.
  >

  > **INFO**
  > https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb
  >

  ```hcl
  # Create LoadBalancer Backend Address Pool
  resource "azurerm_lb_backend_address_pool" "webapp_backend_pool" {
      loadbalancer_id = azurerm_lb.webapp_lb.id
      name            = "test-pool"
  }
  ```

  > **NOTE**
  > ``loadbalancer_id``: Associates the backend pool with the load balancer.
  > ``name``: Defines the name of the backend address pool, which holds the backend VMs.
  >

  ```hcl
  # Create LoadBalancer Health Probe
  resource "azurerm_lb_probe" "webapp_http_probe" {
      loadbalancer_id = azurerm_lb.webapp_lb.id
      name            = "test-probe"
      port            = 80
  }
  ```

  > **NOTE**
  > ``loadbalancer_id``: Links the health probe to the load balancer.
  > ``name``: Defines the name of the health probe.
  > ``port``: Specifies the port (80) to check the health of backend instances.
  >

  ```hcl
  # Create Load Balancer Rule
  # This rule will forward traffic from the frontend IP configuration to the backend address pool
  # on port 80 using TCP protocol. It also disables outbound SNAT for the backend pool.
  # The probe is used to check the health of the backend instances.
  resource "azurerm_lb_rule" "example_rule" {
      loadbalancer_id                = azurerm_lb.webapp_lb.id
      name                           = "test-rule"
      protocol                       = "Tcp"
      frontend_port                  = 80
      backend_port                   = 80
      disable_outbound_snat          = true
      frontend_ip_configuration_name = "frontend-${var.initials}${var.random_string}"
      probe_id                       = azurerm_lb_probe.webapp_http_probe.id
      backend_address_pool_ids       = [azurerm_lb_backend_address_pool.webapp_backend_pool.id]
  }
  ```

  > **NOTE**
  > ``loadbalancer_id``: Links the rule to the load balancer.
  > ``name``: Defines the name of the load balancer rule.
  > ``protocol``: Specifies the protocol (Tcp) for traffic routing.
  > ``frontend_port``: Defines the port on the frontend IP configuration to listen for traffic (80).
  > ``backend_port``: Specifies the port on the backend instances to forward traffic to (80).
  > ``disable_outbound_snat``: Disables outbound Source Network Address Translation (SNAT) for the backend pool.
  > ``frontend_ip_configuration_name``: References the frontend IP configuration.
  > ``probe_id``: Links the rule to the health probe.
  > ``backend_address_pool_ids``: Specifies the backend address pool for routing traffic.
  >

  ```hcl
  # Create LoadBalancer Outbound SNAT Rule
  resource "azurerm_lb_outbound_rule" "example" {
      name                    = "web-outbound"
      loadbalancer_id         = azurerm_lb.webapp_lb.id
      protocol                = "Tcp"
      backend_address_pool_id = azurerm_lb_backend_address_pool.webapp_backend_pool.id
      frontend_ip_configuration {
          name = "frontend-${var.initials}${var.random_string}"
      }
  }
  ```

  > **NOTE**``name``: Defines the name of the outbound rule.``loadbalancer_id``: Links the rule to the load balancer.``protocol``: Specifies the protocol (Tcp) for outbound traffic.``backend_address_pool_id``: Associates the outbound rule with the backend address pool.``frontend_ip_configuration``:
  >
  > - ``name``: References the frontend IP configuration for outbound traffic.
  >
- The webappServers module provisions multiple virtual machines (VMs) in Azure to serve as application servers for a web application. These VMs are configured with specific settings, such as operating system, size, and network interfaces, and are dynamically associated with the backend pool of a load balancer for traffic distribution.

  #### Module "webappServers"


  ```hcl
  # Create WebApp Servers
  module "webappServers" {
  source = "Azure/avm-res-compute-virtualmachine/azurerm"

      version = "~>0.17.0"
      enable_telemetry = false
      count = var.appServersConfig.vmcount
      resource_group_name = data.azurerm_resource_group.rg.name
      name = "${var.appServersConfig.vmnameprefix}${count.index}" # Unique name per instance
      location = data.azurerm_resource_group.rg.location
      encryption_at_host_enabled = false
      generate_admin_password_or_ssh_key = false
      os_type = "Linux"
      sku_size = var.appServersConfig.vm_sku
      zone = var.appServersConfig.zones[0]
      tags = local.resourceTags
      admin_username = var.appServersConfig.adminUsername
      admin_ssh_keys = [
          {
          public_key = file(var.appServersConfig.key_path)
          username   = var.appServersConfig.adminUsername
          }
      ]
      source_image_reference = {
          publisher = "Canonical"
          offer     = "0001-com-ubuntu-server-focal"
          sku       = "20_04-lts-gen2"
          version   = "latest"
      }
      network_interfaces = {
          nic0 = {
              name = "${var.appServersConfig.vmnameprefix}${count.index}-nic0"
              ip_configurations = {
                  ipconfig0 = {
                      name = "ipconfig1"
                      private_ip_address_allocation = "Dynamic"
                      private_ip_subnet_resource_id = module.virtual_network.subnets["subnet2"].resource_id
                      create_public_ip_address = false
                  }
              }
          }
      }
  }
  ```

  > **NOTE**``source``: Specifies the Azure Verified Module (AVM) for creating virtual machines. Ensures a standardized and reliable deployment.``version``: Specifies the module version (~>0.17.0) to ensure compatibility.``enable_telemetry``: Enables telemetry to track module usage and improve functionality.``count``: Dynamically provisions the number of VMs based on the value of ``var.appServersConfig.vmcount``.``resource_group_name``: Specifies the resource group where the VMs will be deployed.``name``: Dynamically generates a unique name for each VM using the prefix from ``var.appServersConfig.vmnameprefix`` and the instance index.``location``: Specifies the Azure region for the VMs, matching the resource group location.``encryption_at_host_enabled``: Disables encryption at the host level for the VMs.``generate_admin_password_or_ssh_key``: Disables automatic generation of admin credentials or SSH keys.``os_type``: Sets the operating system type to Linux.``sku_size``: Specifies the VM size (SKU) based on ``var.appServersConfig.vm_sku``.``zone``: Specifies the availability zone for the VMs, using the first zone from ``var.appServersConfig.zones``.``tags``: Applies metadata to the VMs using ``local.resourceTags``.``admin_username``: Sets the admin username for the VMs, based on var.appServersConfig.adminUsername.``admin_ssh_keys``: Configures SSH access for the VMs using the public key from ``var.appServersConfig.key_path``.``source_image_reference``: Specifies the VM image
  >
  > - ``publisher``: Canonical (Ubuntu).
  > - ``offer``: Ubuntu Server Focal.
  > - ``sku``: 20.04 LTS Gen2.
  > - ``version``: Latest.``network_interfaces``:Configures the network interface for each VM:
  > - ``name``: Dynamically generates a unique name for the NIC.
  > - ``ip_configurations``:
  >   - ``name``: Defines the name of the IP configuration.
  >   - ``private_ip_address_allocation``: Sets private IP allocation to Dynamic.
  >   - ``private_ip_subnet_resource_id``: Associates the NIC with subnet2 in the virtual network.
  >   - ``create_public_ip_address``: Disables public IP creation for the NIC.
  >

  > **INFO**
  > https://registry.terraform.io/modules/Azure/avm-res-compute-virtualmachine/azurerm/latest
  >

  ```hcl
  # Associate Network Interface to the Backend Pool of the Load Balancer
  resource "azurerm_network_interface_backend_address_pool_association" "example" {
      count                   = var.appServersConfig.vmcount
      network_interface_id    = module.webappServers[count.index].network_interfaces["nic0"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.webapp_backend_pool.id
  }
  ```

  > **NOTE**
  > ``count``: Matches the number of VMs ``var.appServersConfig.vmcount``.
  > ``network_interface_id``: Links each NIC to the corresponding VM's NIC (nic0).
  > ``ip_configuration_name``: Specifies the IP configuration name (ipconfig1).
  > ``backend_address_pool_id``: Associates the NIC with the backend address pool of the load balancer.
  >

---

## --| COMPLETE MAIN.TF |--

When all done your ``main.tf`` should look like this example below:

```hcl
## Import Core Modules   
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"
}

module "regions" {
  source                    = "Azure/avm-utl-regions/azurerm"
  version                   = "0.3.0"
  enable_telemetry          = true
  availability_zones_filter = true
}

module "vm_sku" {
  source  = "Azure/avm-utl-sku-finder/azapi"
  version = "0.3.0"
  location      = data.azurerm_resource_group.rg.location
  cache_results = false
  vm_filters = {
    max_vcpus = 2
  
  }
}

# Create Virtual Network
module "virtual_network" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  address_space       = ["10.0.0.0/24"]
  location            = data.azurerm_resource_group.rg.location
  name                = "vnet-${var.initials}${var.random_string}"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.resourceTags
  subnets = {
    "subnet1" = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.0.0.0/26"]
    }
    "subnet2" = {
      name             = "AppSubnet"
      address_prefixes = ["10.0.0.64/26"]
    }
  }
}

# Create a Network Security Group
resource "azurerm_network_security_group" "app_subnet_nsg" {
  name                = "AppSubnetNSG"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.0.0/24"
  }

  tags = local.resourceTags
}

# Associate the NSG with the AppSubnet
resource "azurerm_subnet_network_security_group_association" "app_subnet_nsg_association" {
  subnet_id                 = module.virtual_network.subnets["subnet2"].resource_id  
  network_security_group_id = azurerm_network_security_group.app_subnet_nsg.id
}

# Create Azure Bastion Host
module "azure_bastion" {
  source = "Azure/avm-res-network-bastionhost/azurerm"

  enable_telemetry    = false
  name                = "bastion_${var.initials}${var.random_string}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  copy_paste_enabled  = true
  file_copy_enabled   = true
  sku                 = "Standard"
  ip_connect_enabled     = true
  shareable_link_enabled = true
  tunneling_enabled      = true
  kerberos_enabled       = true
  ip_configuration = {
    name                 = "my-ipconfig"
    subnet_id            = module.virtual_network.subnets["subnet1"].resource_id
    create_public_ip     = true
    public_ip_address_name = "bastionpip-${var.initials}${var.random_string}"
  }
  tags = local.resourceTags
}


# Create Azure Public IP for LoadBalancer
resource "azurerm_public_ip" "webapp_lb_pip" {
  name                = "lbpip${var.initials}${var.random_string}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = local.resourceTags
}

# Create Azure Load Balancer
resource "azurerm_lb" "webapp_lb" {
  name                = "lb-${var.initials}${var.random_string}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"

frontend_ip_configuration {
    name                 = "frontend-${var.initials}${var.random_string}"
    public_ip_address_id = azurerm_public_ip.webapp_lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "webapp_backend_pool" {
  loadbalancer_id = azurerm_lb.webapp_lb.id
  name            = "test-pool"
}

resource "azurerm_lb_probe" "webapp_http_probe" {
  loadbalancer_id = azurerm_lb.webapp_lb.id
  name            = "test-probe"
  port            = 80
}

# Create Load Balancer Rule
# This rule will forward traffic from the frontend IP configuration to the backend address pool
# on port 80 using TCP protocol. It also disables outbound SNAT for the backend pool.
# The probe is used to check the health of the backend instances.
resource "azurerm_lb_rule" "example_rule" {
  loadbalancer_id                = azurerm_lb.webapp_lb.id
  name                           = "test-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "frontend-${var.initials}${var.random_string}"
  probe_id                       = azurerm_lb_probe.webapp_http_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.webapp_backend_pool.id]
}


resource "azurerm_lb_outbound_rule" "example" {
  name                    = "web-outbound"
  loadbalancer_id         = azurerm_lb.webapp_lb.id
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.webapp_backend_pool.id
  frontend_ip_configuration {
    name = "frontend-${var.initials}${var.random_string}"
  }
}


# Create WebApp Servers
module "webappServers" {
    source = "Azure/avm-res-compute-virtualmachine/azurerm"
    version = "~>0.17.0"
    enable_telemetry = true
    count = var.appServersConfig.vmcount
    resource_group_name = data.azurerm_resource_group.rg.name
    name = "${var.appServersConfig.vmnameprefix}${count.index}" # Unique name per instance
    location = data.azurerm_resource_group.rg.location
    encryption_at_host_enabled = false
    generate_admin_password_or_ssh_key = false
    os_type = "Linux"
    sku_size = var.appServersConfig.vm_sku
    zone = var.appServersConfig.zones[0]
    tags = local.resourceTags
    admin_username = var.appServersConfig.adminUsername
    admin_ssh_keys = [
        {
        public_key = file(var.appServersConfig.key_path)
        username   = var.appServersConfig.adminUsername
        }
    ]
    source_image_reference = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-focal"
        sku       = "20_04-lts-gen2"
        version   = "latest"
    }
    network_interfaces = {
        nic0 = {
            name = "${var.appServersConfig.vmnameprefix}${count.index}-nic0"
            ip_configurations = {
                ipconfig0 = {
                    name = "ipconfig1"
                    private_ip_address_allocation = "Dynamic"
                    private_ip_subnet_resource_id = module.virtual_network.subnets["subnet2"].resource_id
                    create_public_ip_address = false
                }
            }
        }
    }
}

# Associate Network Interface to the Backend Pool of the Load Balancer
resource "azurerm_network_interface_backend_address_pool_association" "example" {
  count                   = var.appServersConfig.vmcount
  network_interface_id    = module.webappServers[count.index].network_interfaces["nic0"].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.webapp_backend_pool.id
}
```

---

Now you are ready to start running the terrafrom init, plan, apply commands and build out your infrastructure. That is the next lab.

# End of Lab

[⬅ Back to LABGUIDE](LABGUIDE.md) | [Next to LAB03 ➡](LAB03.md)
