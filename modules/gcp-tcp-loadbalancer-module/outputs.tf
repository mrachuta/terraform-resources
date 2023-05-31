output "lb_ip_output" {
  value = var.external_lb == true ? (
    google_compute_forwarding_rule.external_lb[0].ip_address
  ) : (
    google_compute_forwarding_rule.internal_lb[0].ip_address
  )
}

output "lb_ip_output_clickable_http" {
  value = var.external_lb == true ? (
    var.http_port == 80 ? (
      "http://${google_compute_forwarding_rule.external_lb[0].ip_address}/"
    ) : (
      "http://${google_compute_forwarding_rule.external_lb[0].ip_address}:${var.http_port}/"
    )
  ) : (
    var.http_port == 80 ? (
      "http://${google_compute_forwarding_rule.internal_lb[0].ip_address}/"
    ) : (
      "http://${google_compute_forwarding_rule.internal_lb[0].ip_address}:${var.http_port}/"
    )
  )
}

output "lb_ip_output_clickable_https" {
  value = var.external_lb == true ? (
    var.https_port != null ? (
      var.https_port == 443 ? (
        "http://${google_compute_forwarding_rule.external_lb[0].ip_address}/"
      ) : (
        "https://${google_compute_forwarding_rule.external_lb[0].ip_address}:${var.https_port}/"
      )
    ) : null
  ) : (
    var.https_port != null ? (
      var.https_port == 443 ? (
        "http://${google_compute_forwarding_rule.internal_lb[0].ip_address}/"
      ) : (
        "https://${google_compute_forwarding_rule.internal_lb[0].ip_address}:${var.https_port}/"
      )
    ) : null
  )
}
