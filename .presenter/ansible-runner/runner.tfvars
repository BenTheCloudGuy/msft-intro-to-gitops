# Lab Configurations
initials      = "bmm"
random_string = "sidvgl"

## Tag Vars
tags = {
  "Owner"       = "Ben Mitchell"
  "Environment" = "Github Runner"
}

## App Server Confiugurations
appServersConfig = {
  vmnameprefix  = "webapp"
  vmcount       = 1
  adminUsername = "labAdmin"
  zones         = ["3"]
  key_path      = "/home/vscode/.ssh/ansible.pub"
  vm_sku        = "Standard_D2s_v6"
}