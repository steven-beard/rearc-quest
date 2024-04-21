terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  required_version = ">= 1.6.0"
  backend "s3" {
    bucket         = "rearc-terraform-state-sbeard"
    key            = "quest-infra/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "rearc-terraform-state"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = local.tags
  }
}
