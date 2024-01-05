variable "project_name" {
  type    = string
  default = "myproject"
}

variable "network_name" {
  type    = string
  default = "example-network"
}

variable "router_region" {
  type    = string
  default = "us-central1"
}

variable "subnetworks" {
  type = map(object(
    {
      ip_cidr_range     = string
      subnetwork_region = string
    }
  ))
  default = {
    subnetwork-01 = {
      ip_cidr_range     = "10.0.1.0/24"
      subnetwork_region = "us-central1"
    }
  }
}
