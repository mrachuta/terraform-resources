output "network_id_output" {
  value = google_compute_network.vpc_network.id
}

output "subnetworks_output" {
  value = google_compute_subnetwork.subnetwork.*
}
