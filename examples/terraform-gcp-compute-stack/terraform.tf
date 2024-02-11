terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.80.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.80.0"
    }
  }
}

provider "google" {
  # All configured using ENV variables in .env file
  # Run following command to export: export $(cat .env | xargs)
  # GOOGLE_APPLICATION_CREDENTIALS="path/to/file.json"
  # GOOGLE_PROJECT="myproject
  # GOOGLE_REGION="us-central1"
  # GOOGLE_ZONE="us-central1-b"
  # 
}
