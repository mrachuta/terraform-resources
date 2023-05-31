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

variable "mig_service_account_id" {
  type    = string
  default = "example-mig-sa"
}

variable "mig_service_account_description" {
  type    = string
  default = "Example SA created for MIG purposes"
}

variable "mig_name" {
  type    = string
  default = "example-mig"
}

variable "mig_description" {
  type    = string
  default = "Example MIG"
}

variable "mig_image" {
  type    = string
  default = "debian-cloud/debian-11"
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