output "instance_group_output" {
  value = google_compute_instance_group_manager.mig.instance_group
}

output "network_name_output" {
  value = google_compute_network.vpc_network.name
}
