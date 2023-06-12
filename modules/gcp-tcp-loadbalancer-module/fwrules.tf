locals {
  rule_prefix = length(
    regexall("^projects/.*/global/networks/.*$", var.network_name)
  ) > 0 ? element(split("/", var.network_name), 4) : var.network_name
}

resource "google_compute_firewall" "rule_ingress_allow_lb_hc" {
  name      = "${local.rule_prefix}-in-a-lb-hc-to-${var.lb_name}"
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

resource "google_compute_firewall" "rule_ingress_allow_client_to_external_lb" {
  count     = var.external_lb == true ? 1 : 0
  name      = "${local.rule_prefix}-in-a-client-to-${var.lb_name}"
  direction = "INGRESS"
  network   = var.network_name

  source_ranges = [
    "0.0.0.0/0"
  ]

  destination_ranges = [
    "${google_compute_forwarding_rule.external_lb[0].ip_address}/32"
  ]

  depends_on = [
    google_compute_forwarding_rule.external_lb
  ]

  allow {
    protocol = "tcp"
    # Use compact() to remove null and empty values
    ports = compact([
      var.http_port,
      var.https_port
    ])
  }
}
