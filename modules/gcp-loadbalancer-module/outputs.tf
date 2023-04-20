output "lb_ip_output" {
    value = google_compute_forwarding_rule.external_lb.ip_address
}

output "lb_ip_output_clickable" {
    value = "http://${google_compute_forwarding_rule.external_lb.ip_address}/"
}
