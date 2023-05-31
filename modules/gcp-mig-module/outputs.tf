output "instance_group_output" {
  value = google_compute_instance_group_manager.mig.instance_group
}

output "network_name_output" {
  value = google_compute_network.vpc_network.name
}

output "subnetwork_name_output" {
  value = google_compute_subnetwork.mig_subnetwork.name
}

output "http_port_output" {
  value = var.http_port != null ? var.http_port : null
}

output "https_port_output" {
  value = var.https_port != null ? var.https_port : null
}
