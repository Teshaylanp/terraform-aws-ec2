provider "aws" {
  region = local.region

}

terraform {
  required_version = "v1.13.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.18.0"
    }
  }
}
