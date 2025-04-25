locals {
  ## Add Current Date/Time tag
  resourceTags = merge(
    var.tags,
    {
      DeploymentUTC = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp()),
    }
  )
}