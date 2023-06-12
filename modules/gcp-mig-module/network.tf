resource "google_compute_network" "vpc_network" {
  count                   = var.create_network == true ? 1 : 0
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mig_subnetwork" {
  count         = var.create_subnetwork == true ? 1 : 0
  name          = "${var.network_name}-mig-subnet"
  ip_cidr_range = var.network_ip_range
  region        = var.mig_region
  network = (
    var.create_network == true ?
    google_compute_network.vpc_network[0].name : var.network_name
  )
}
