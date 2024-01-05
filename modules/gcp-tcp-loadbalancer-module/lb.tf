resource "google_compute_forwarding_rule" "external_lb" {
  count                 = var.external_lb == true ? 1 : 0
  name                  = "${var.lb_name}-forwarding-rule"
  region                = var.lb_region
  load_balancing_scheme = "EXTERNAL"
  backend_service       = google_compute_region_backend_service.lb_backend.id

  ports = compact([
    var.http_port,
    var.https_port
  ])

  depends_on = [
    google_compute_region_backend_service.lb_backend
  ]

}

resource "google_compute_address" "internal_lb_address" {
  count        = var.lb_custom_ip_address == null ? 0 : 1
  name         = "${var.lb_name}-forwarding-rule-ip-address"
  subnetwork   = var.subnetwork_name
  address_type = "INTERNAL"
  address      = var.lb_custom_ip_address
  region       = var.lb_region
}

resource "google_compute_forwarding_rule" "internal_lb" {
  count                 = var.external_lb == true ? 0 : 1
  name                  = "${var.lb_name}-forwarding-rule"
  region                = var.lb_region
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.lb_backend.id
  network               = var.network_name
  subnetwork            = var.subnetwork_name
  ip_address = coalesce(
    google_compute_address.internal_lb_address[0].address,
    null
  )

  ports = compact([
    var.http_port,
    var.https_port
  ])

  depends_on = [
    google_compute_region_backend_service.lb_backend
  ]

}

resource "google_compute_region_backend_service" "lb_backend" {
  name                  = "${var.lb_name}-backend"
  region                = var.lb_region
  load_balancing_scheme = var.external_lb == true ? "EXTERNAL" : "INTERNAL"
  health_checks         = [google_compute_region_health_check.lb_hc.id]

  backend {
    group = var.mig_name
  }

  depends_on = [
    google_compute_region_health_check.lb_hc
  ]

}

resource "google_compute_region_health_check" "lb_hc" {
  name               = "${var.lb_name}-backend-hc"
  check_interval_sec = 1
  timeout_sec        = 1
  region             = var.lb_region

  tcp_health_check {
    port = var.https_port != null ? var.https_port : var.http_port
  }

}
