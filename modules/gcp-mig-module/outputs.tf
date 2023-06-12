output "instance_group_output" {
  value = google_compute_instance_group_manager.mig.instance_group
}

output "network_name_output" {
  value = var.create_network == true ? google_compute_network.vpc_network[0].name : var.network_name
}

output "subnetwork_name_output" {
  value = var.create_subnetwork == true ? google_compute_subnetwork.mig_subnetwork[0].name : var.subnetwork_name
}

output "http_port_output" {
  value = var.http_port != null ? var.http_port : null
}

output "https_port_output" {
  value = var.https_port != null ? var.https_port : null
}

output "mig_image_output" {
  value = google_compute_instance_template.mig_template.disk.0.source_image
}
