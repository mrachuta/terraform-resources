variable "lb_region" {
  type    = string
  default = "us-central1"
}

variable "lb_name" {
  type    = string
  default = "example-lb"
}

variable "mig_name" {
  type    = string
  default = "example-mig"
}

variable "network_name" {
  type    = string
  default = "example-network"
}

variable "http_port" {
  type    = number
  default = 80
}

variable "https_port" {
  type    = number
  default = null
}
