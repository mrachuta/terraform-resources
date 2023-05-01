data "google_storage_project_service_account" "default" {
}

resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  count         = var.bucket_encryption ? 1 : 0
  crypto_key_id = var.bucket_kms_key_path
  role          = "roles/cloudkms.cryptoOperator"
  members = [
    "serviceAccount:${data.google_storage_project_service_account.default.email_address}"
  ]
}
