terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }

  required_version = "~> 1.4.0"

}

provider "google" {
  credentials = file("../kr-free-2023-3d7a95551eec.json")

  project = "kr-free-2023"
  region  = "us-central1"
  zone    = "us-central1-b"
}
