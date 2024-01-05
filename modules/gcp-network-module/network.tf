resource "google_compute_network" "vpc_network" {
  project                 = var.project_name
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  for_each      = var.subnetworks
  name          = "${var.network_name}-${each.key}"
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.subnetwork_region
  network       = google_compute_network.vpc_network.id
}
