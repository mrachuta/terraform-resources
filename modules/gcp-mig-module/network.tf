resource "google_compute_network" "vpc_network" {
  project                 = data.google_client_config.current.project
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mig_subnetwork" {
  name          = "${var.network_name}-mig-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = data.google_client_config.current.region
  network       = google_compute_network.vpc_network.id

  depends_on = [
    google_compute_network.vpc_network
  ]
}
