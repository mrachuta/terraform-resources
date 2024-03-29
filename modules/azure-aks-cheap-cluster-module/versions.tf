terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.92.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">=2.12"
    }
  }
}
