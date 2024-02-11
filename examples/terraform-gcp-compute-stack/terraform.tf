terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.15.0"
    }
  }

  required_version = ">= 1.4.0"
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
