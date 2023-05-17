
resource "google_compute_instance_template" "mig_template" {
  name_prefix = "${var.mig_name}-template-"
  description = "Template to create ${var.mig_name} MIG"

  tags = concat(
    [
      "foo",
      "bar"
    ],
    var.mig_additional_tags
  )


  labels = merge(
    {
      environment = "dev"
    },
    var.mig_additional_labels
  )

  instance_description = var.mig_description
  machine_type         = "e2-medium"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true

    dynamic "disk_encryption_key" {
      for_each = var.mig_disk_encryption ? [1] : []
      content {
        kms_key_self_link = var.mig_disk_kms_key_path
      }
    }
  }

  network_interface {
    subnetwork = "${var.network_name}-mig-subnet"
  }

  metadata = {
    foo               = "bar"
    nginx_bucket_name = var.nginx_bucket_name
    ssl_enabled       = var.https_port != null ? "true" : "false"
  }

  metadata_startup_script = <<EOF
    #!/bin/bash

    sudo apt -y update
    sudo apt -y install nginx
    nginx_bucket=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/nginx_bucket_name" -H "Metadata-Flavor: Google")
    if [ "$nginx_bucket" == 'none' ]; then
      echo 'nginx_bucket flag set to none...'
      vm_name=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/hostname" -H "Metadata-Flavor: Google")
      int_ip=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")
      echo "<h2>Hello from $vm_name at $int_ip</h2>" > /var/www/html/index.nginx-debian.html
    else
      echo 'nginx_bucket flag found...'
      site_name=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/nginx_bucket_name" -H "Metadata-Flavor: Google")
      mkdir /var/www/html/${var.site_name}
      gsutil cp -R gs://${var.nginx_bucket_name}/*.{html,htm} /var/www/html/${var.site_name}/
      gsutil cp -R gs://${var.nginx_bucket_name}/custom.conf /etc/nginx/sites-available/custom.conf
      gsutil cp -R gs://${var.nginx_bucket_name}/nginx.conf /etc/nginx/nginx.conf
      chown -R www-data:www-data /var/www/html/${var.site_name}
      chown www-data:www-data /etc/nginx/sites-available/custom.conf /etc/nginx/nginx.conf
      ssl_enabled=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/ssl_enabled" -H "Metadata-Flavor: Google")
      if [ "$ssl_enabled" == 'true' ]; then
        echo 'ssl_enabled flag found...'
        mkdir /etc/ssl/${var.site_name}
        gsutil cp -R gs://${var.nginx_bucket_name}/*.{crt,key} /etc/ssl/${var.site_name}/
        chown -R www-data:www-data /etc/ssl/${var.site_name}
      fi
      ln -s /etc/nginx/sites-available/custom.conf /etc/nginx/sites-enabled/custom.conf
      rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default
    fi
    sudo systemctl enable --now nginx
    sudo systemctl restart nginx
    EOF

  service_account {
    email = google_service_account.mig_service_account.email
    scopes = [
      "cloud-platform"
    ]
  }

  depends_on = [
    google_compute_subnetwork.mig_subnetwork,
    google_kms_crypto_key_iam_binding.crypto_key
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "mig" {
  name               = var.mig_name
  base_instance_name = "${var.mig_name}-inst"
  zone               = var.mig_zone

  version {
    name              = "${var.mig_name}-template"
    instance_template = google_compute_instance_template.mig_template.self_link
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 2
    max_unavailable_fixed = 0
  }

  target_size = var.mig_size

  auto_healing_policies {
    health_check      = google_compute_health_check.mig_hc.id
    initial_delay_sec = 300
  }

  depends_on = [
    google_compute_instance_template.mig_template
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "mig_hc" {
  name                = "${var.mig_name}-mig-hc"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  tcp_health_check {
    port = var.https_port != null ? var.https_port : var.http_port
  }
}
