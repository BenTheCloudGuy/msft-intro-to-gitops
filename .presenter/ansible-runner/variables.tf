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