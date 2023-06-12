resource "google_compute_router" "router" {
  count   = var.create_network == true ? 1 : 0
  name    = "${var.network_name}-router"
  region  = var.mig_region
  network = var.network_name

  bgp {
    asn = 64514
  }

  depends_on = [
    google_compute_network.vpc_network
  ]
}

resource "google_compute_router_nat" "nat_router" {
  count                              = var.create_network == true ? 1 : 0
  name                               = "${var.network_name}-nat-router"
  router                             = google_compute_router.router[0].name
  region                             = google_compute_router.router[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
