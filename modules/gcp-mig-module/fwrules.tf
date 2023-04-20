resource "google_compute_firewall" "rule_allow_internal" {
  name      = "${var.network_name}-allow-internal"
  direction = "INGRESS"
  network   = var.network_name

  source_ranges = [
    "10.0.1.0/24",
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
