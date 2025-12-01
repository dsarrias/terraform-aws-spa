terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
      
      configuration_aliases = [aws.useast1]
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 2.1.0"
    }
  }
}
