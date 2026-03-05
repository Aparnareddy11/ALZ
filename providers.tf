locals {
  alz_library_references = concat(
    [
      {
        path = "platform/alz"
        ref  = "2025.09.0"
      }
    ],
    fileexists("${path.root}/lib") ? [
      {
        custom_url = "${path.root}/lib"
      }
    ] : []
  )
}

provider "alz" {
  library_overwrite_enabled = true
  library_references        = local.alz_library_references
}

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }

    alz = {
      source  = "azure/alz"
      version = "~> 0.20"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0, >= 2.0.1"
    }
  }
}
