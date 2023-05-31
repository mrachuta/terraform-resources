# resource "google_compute_subnetwork" "lb_subnetwork" {
#   name          = "${var.network_name}-lb-subnet"
#   ip_cidr_range = "10.0.2.0/24"
#   region        = var.lb_region
#   network       = var.network_name
# }
