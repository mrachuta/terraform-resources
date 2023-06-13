output "bucket_name_output" {
  value = google_storage_bucket.nginx_bucket.name
}

output "site_name_output" {
  value = var.site_name
}

output "http_port_output" {
  value = var.http_port
}

output "https_port_output" {
  value = var.https_port
}
