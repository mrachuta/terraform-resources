resource "tls_private_key" "ca" {
  count     = var.generate_cert ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  count           = var.generate_cert ? 1 : 0
  private_key_pem = tls_private_key.ca[0].private_key_pem

  subject {
    common_name  = var.site_name
    organization = "ACME"
  }

  allowed_uses = [
    "key_encipherment",
    "cert_signing",
    "server_auth",
    "client_auth",
  ]

  validity_period_hours = 24000
  early_renewal_hours   = 720
  is_ca_certificate     = true
}

resource "tls_private_key" "default" {
  count     = var.generate_cert ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "default" {
  count           = var.generate_cert ? 1 : 0
  private_key_pem = tls_private_key.default[0].private_key_pem

  dns_names = concat(
    [
      "${var.site_name}",
      "www.${var.site_name}",
    ],
    var.additional_dns_names
  )

  subject {
    common_name  = var.site_name
    organization = "ACME"
  }
}

resource "tls_locally_signed_cert" "default" {
  count              = var.generate_cert ? 1 : 0
  cert_request_pem   = tls_cert_request.default[0].cert_request_pem
  ca_private_key_pem = tls_private_key.ca[0].private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca[0].cert_pem

  validity_period_hours = 42000

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

data "template_file" "nginx_custom_file" {
  template = file("${path.module}/resources/custom.conf.tpl")
  vars = {
    site_name = var.site_name
    http_port = var.http_port
    # Template can't handle null for templating?
    https_port = var.https_port != null ? var.https_port : "null"
  }
}

resource "google_storage_bucket_object" "custom_conf_file" {
  name    = "custom.conf"
  content = data.template_file.nginx_custom_file.rendered
  bucket  = google_storage_bucket.nginx_bucket.name
}

resource "google_storage_bucket_object" "selfsigned_cert" {
  count   = var.generate_cert ? 1 : 0
  name    = "${var.site_name}.crt"
  content = tls_locally_signed_cert.default[0].cert_pem
  bucket  = google_storage_bucket.nginx_bucket.name
}

resource "google_storage_bucket_object" "selfsigned_key" {
  count   = var.generate_cert ? 1 : 0
  name    = "${var.site_name}.key"
  content = tls_private_key.default[0].private_key_pem
  bucket  = google_storage_bucket.nginx_bucket.name
}

resource "google_storage_bucket_object" "nginx_conf" {
  name    = "nginx.conf"
  content = file("${path.module}/resources/nginx.conf")
  bucket  = google_storage_bucket.nginx_bucket.name
}

resource "google_storage_bucket_object" "additional_files" {
  for_each = var.additional_bucket_files
  name     = each.value.bucket_file_name
  content  = each.value.bucket_file_content
  bucket   = google_storage_bucket.nginx_bucket.name
}
