output "lb_ip_output" {
  value = google_compute_forwarding_rule.external_lb.ip_address
}

output "lb_ip_output_clickable_http" {
  value = var.http_port == "80" ? (
    "http://${google_compute_forwarding_rule.external_lb.ip_address}/"
  ) : (
    "http://${google_compute_forwarding_rule.external_lb.ip_address}:${var.http_port}/"
  )
}

output "lb_ip_output_clickable_https" {
  value = var.https_port != null ? (
    var.https_port == "443" ? (
      "http://${google_compute_forwarding_rule.external_lb.ip_address}/"
     ) : (
      "https://${google_compute_forwarding_rule.external_lb.ip_address}:${var.https_port}/"
     )
  ) : null
}
