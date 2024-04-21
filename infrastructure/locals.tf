data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  name          = "quest"
  base_domain   = "sbeard.cloud"
  domain_prefix = "rearc"

  tags = {
    App       = local.name
    ManagedBy = "Terraform"
  }
}
