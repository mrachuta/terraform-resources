data "google_project" "this" {}

resource "google_project_iam_binding" "mig_service_account_bucket_reader_role" {
  count   = var.nginx_bucket_name != null ? 1 : 0
  project = var.project_name
  role    = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${var.mig_service_account_email}",
  ]
}

resource "google_project_iam_binding" "mig_service_account_additional_roles" {
  for_each = var.mig_service_account_additional_roles
  project  = var.project_name
  role     = each.value
  members = [
    "serviceAccount:${var.mig_service_account_email}",
  ]
}

resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  count         = var.mig_disk_encryption == true ? 1 : 0
  crypto_key_id = var.mig_disk_kms_key_path
  role          = "roles/cloudkms.cryptoOperator"
  members = [
    "serviceAccount:service-${data.google_project.this.number}@compute-system.iam.gserviceaccount.com",
  ]
}
