resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
  project  = var.project_name
}

resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  count         = var.db_encryption == true ? 1 : 0
  crypto_key_id = var.db_kms_key_path
  role          = "roles/cloudkms.cryptoOperator"
  members = [
    "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}",
  ]
}

resource "google_project_iam_binding" "cloud_sql_user_role" {
  for_each = var.db_users
  project  = var.project_name
  role     = "roles/cloudsql.instanceUser"
  members = [
    each.value.user,
  ]
}
