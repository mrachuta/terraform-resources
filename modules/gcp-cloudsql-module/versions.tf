terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.80.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      # Required because of: 
      # https://github.com/hashicorp/terraform-provider-google/issues/16275#issuecomment-1825752152
      version = "~>4"
    }
  }
}
