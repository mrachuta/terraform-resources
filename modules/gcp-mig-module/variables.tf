variable "project_name" {
  type    = string
  default = "myproject"
}

variable "mig_region" {
  type    = string
  default = "us-central1"
}

variable "mig_zone" {
  type    = string
  default = "us-central1-b"
}

variable "mig_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "mig_service_account_email" {
  type    = string
  default = "example-mig-sa@myproject.iam.gserviceaccount.com"
}

variable "mig_service_account_additional_roles" {
  type    = map(string)
  default = {}
}

variable "mig_name" {
  type    = string
  default = "example-mig"
}

variable "mig_description" {
  type    = string
  default = "Example MIG"
}

variable "mig_image_family_link" {
  type    = string
  default = "projects/debian-cloud/global/images/family/debian-11"
}

variable "mig_specific_image_link" {
  type    = string
  default = null
}

variable "mig_size" {
  type    = string
  default = "3"
}

variable "mig_startup_script" {
  type    = string
  default = null
}

variable "mig_additional_tags" {
  type    = list(any)
  default = []
}

variable "mig_additional_labels" {
  type    = map(string)
  default = {}
}

variable "mig_additional_metadata" {
  type    = map(string)
  default = {}
}

variable "mig_disk_encryption" {
  type    = bool
  default = false
}

variable "mig_disk_kms_key_path" {
  type    = string
  default = null
}

variable "nginx_bucket_name" {
  type    = string
  default = null
}

variable "site_name" {
  type    = string
  default = null
}

variable "http_port" {
  type    = number
  default = 80
}

variable "https_port" {
  type    = number
  default = null
}

variable "create_network" {
  type    = bool
  default = false
}

variable "create_subnetwork" {
  type    = bool
  default = false
}

variable "network_name" {
  type    = string
  default = "example-network"
}

variable "subnetwork_name" {
  type    = string
  default = "example-subnetwork"
}

variable "additional_networks" {
  type = map(object(
    {
      network_name    = string
      subnetwork_name = string
    }
  ))
  default = {}
}

variable "network_ip_range" {
  type    = string
  default = "10.0.1.0/24"
}