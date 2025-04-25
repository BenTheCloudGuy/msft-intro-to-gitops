output "ResourceGroupName" {
  value = data.azurerm_resource_group.rg.name
}

output "AzureRegion" {
  value = data.azurerm_resource_group.rg.location
}


output "vm_resourceId" {
  value = [
    for vm in module.ghrunner : vm.resource_id
  ]
}
