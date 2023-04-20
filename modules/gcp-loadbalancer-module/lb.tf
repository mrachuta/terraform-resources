resource "google_compute_forwarding_rule" "external_lb" {
  name            = "${var.lb_name}-forwarding-rule"
  region          = var.lb_region
  port_range      = 80
  backend_service = google_compute_region_backend_service.lb_backend.id

  depends_on = [
    google_compute_region_backend_service.lb_backend
  ]

}

resource "google_compute_region_backend_service" "lb_backend" {
  name                  = "${var.lb_name}-backend"
  region                = var.lb_region
  load_balancing_scheme = "EXTERNAL"
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
    port = "80"
  }

}
