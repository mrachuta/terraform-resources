resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mig_subnetwork" {
  name          = "${var.network_name}-mig-subnet"
  ip_cidr_range = var.network_ip_range
  region        = var.mig_region
  network       = google_compute_network.vpc_network.id

  depends_on = [
    google_compute_network.vpc_network
  ]
}
