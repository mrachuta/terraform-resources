resource "google_storage_bucket" "nginx_bucket" {
  name          = var.bucket_name
  location      = var.bucket_region
  force_destroy = true

  uniform_bucket_level_access = true

  storage_class = "STANDARD"

  versioning {
    enabled = false
  }

  # Suggestion from https://stackoverflow.com/a/70594607
  dynamic "encryption" {
    for_each = var.bucket_encryption ? [1] : []
    content {
      default_kms_key_name = var.bucket_kms_key_path
    }
  }
}
