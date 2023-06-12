variable "lb_region" {
  type    = string
  default = "us-central1"
}

variable "lb_name" {
  type    = string
  default = "example-lb"
}

variable "external_lb" {
  type    = bool
  default = true
}

variable "lb_custom_ip_address" {
  type    = string
  default = null
}

variable "mig_name" {
  type    = string
  default = "example-mig"
}

variable "network_name" {
  type    = string
  default = "example-network"
}

variable "subnetwork_name" {
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
