variable "mig_region" {
  type    = string
  default = "us-central1"
}

variable "mig_zone" {
  type    = string
  default = "us-central1-b"
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

variable "mig_size" {
  type    = string
  default = "3"
}

variable "mig_additional_tags" {
  type    = list(any)
  default = []
}

variable "mig_additional_labels" {
  type    = map(string)
  default = {}
}

variable "network_name" {
  type    = string
  default = "example-network"
}
