data "google_project" "this" {}

resource "google_service_account" "mig_service_account" {
  account_id   = var.mig_service_account_id
  display_name = var.mig_service_account_description
}

resource "google_project_iam_binding" "mig_service_account_bucket_reader_role" {
  count   = var.nginx_bucket_name != null ? 1 : 0
  project = var.project_name
  role    = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.mig_service_account.email}",
  ]
}

resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  count         = var.mig_disk_encryption ? 1 : 0
  crypto_key_id = var.mig_disk_kms_key_path
  role          = "roles/cloudkms.cryptoOperator"
  members = [
    "serviceAccount:service-${data.google_project.this.number}@compute-system.iam.gserviceaccount.com",
  ]
}
