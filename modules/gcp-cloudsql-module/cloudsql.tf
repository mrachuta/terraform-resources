resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  project       = var.project_name
  name          = "${var.db_instance_name}-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_name
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = var.network_name
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  provider = google-beta

  project          = var.project_name
  name             = "${var.db_instance_name}-${random_id.db_name_suffix.hex}"
  region           = var.db_region
  database_version = var.db_version

  depends_on = [google_service_networking_connection.private_vpc_connection]

  deletion_protection = var.db_deletion_protection

  encryption_key_name = (
    var.db_encryption != true ? null : var.db_kms_key_path
  )

  settings {
    tier = var.db_instance_size
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
    ip_configuration {
      ipv4_enabled = false
      # TODO: move to locals and enable all input types
      private_network                               = var.network_name
      enable_private_path_for_google_cloud_services = true
    }
  }
}

resource "google_sql_database" "database" {
  for_each = var.db_names
  name     = each.value
  instance = google_sql_database_instance.instance.name

  # Prevent issues with deletion of user if database objects exists
  depends_on = [ 
    google_sql_user.users
  ]
}

resource "google_sql_user" "users" {
  for_each = var.db_users
  name = trimprefix(
    trimsuffix(each.value.user, ".gserviceaccount.com"),
    "serviceAccount:"
  )
  instance = google_sql_database_instance.instance.name
  type     = each.value.type
}
