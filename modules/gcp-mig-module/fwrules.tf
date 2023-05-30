resource "google_compute_firewall" "rule_ingress_allow_internal_all" {
  name      = "${var.network_name}-ingres-allow-internal-all"
  direction = "INGRESS"
  network   = var.network_name

  source_ranges = [
    var.network_ip_range
  ]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  depends_on = [
    google_compute_network.vpc_network
  ]
}

resource "google_compute_firewall" "rule_egress_allow_internal_all" {
  name      = "${var.network_name}-egress-allow-internal-all"
  direction = "EGRESS"
  network   = var.network_name

  source_ranges = [
    var.network_ip_range
  ]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  depends_on = [
    google_compute_network.vpc_network
  ]
}

resource "google_compute_firewall" "rule_ingress_allow_iap" {
  name      = "${var.network_name}-ingress-allow-iap"
  direction = "INGRESS"
  network   = var.network_name

  source_ranges = [
    "35.235.240.0/20"
  ]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  depends_on = [
    google_compute_network.vpc_network
  ]

}
