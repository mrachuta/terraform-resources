resource "google_compute_firewall" "rule_lb_hc" {
  name      = "${var.network_name}-allow-lb-hc-to-mig"
  direction = "INGRESS"
  network   = var.network_name

  source_ranges = [
    "35.191.0.0/16",
    "209.85.152.0/22",
    "209.85.204.0/22"
  ]

  allow {
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "rule_lb_client" {
  name      = "${var.network_name}-allow-client-to-lb"
  direction = "INGRESS"
  network   = var.network_name

  source_ranges = [
    "0.0.0.0/0",
  ]

  destination_ranges = [
    "${google_compute_forwarding_rule.default.ip_address}/32"
  ]

  depends_on = [
    google_compute_forwarding_rule.default
  ]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
