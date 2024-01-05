locals {
  rule_prefix = length(
    regexall("^projects/.*/global/networks/.*$", var.network_name)
  ) > 0 ? element(split("/", var.network_name), 4) : var.network_name
}

resource "google_compute_firewall" "rule_ingress_allow_internal_all" {
  name      = "${local.rule_prefix}-in-a-internal-all"
  direction = "INGRESS"
  network   = var.network_name

  source_ranges = [
    for k, v in var.subnetworks : v.ip_cidr_range
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
  name      = "${local.rule_prefix}-eg-a-internal-all"
  direction = "EGRESS"
  network   = var.network_name

  source_ranges = [
    for k, v in var.subnetworks : v.ip_cidr_range
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
  name      = "${local.rule_prefix}-in-allow-iap"
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
