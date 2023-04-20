resource "google_service_account" "mig_service_account" {
  account_id   = var.mig_service_account_id
  display_name = var.mig_service_account_description
}

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
  }

  network_interface {
    subnetwork = "${var.network_name}-mig-subnet"
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = <<EOF
    #!/bin/bash

    sudo apt -y update
    sudo apt -y install nginx
    export VM_NAME=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/hostname" -H "Metadata-Flavor: Google")
    export INT_IP=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")
    echo "<h2>Hello from $VM_NAME at $INT_IP</h2>" > /var/www/html/index.nginx-debian.html
    sudo systemctl enable --now nginx
    EOF

  service_account {
    email  = google_service_account.mig_service_account.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    google_compute_subnetwork.mig_subnetwork
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "mig" {
  name               = var.mig_name
  base_instance_name = "${var.mig_name}-inst"
  zone               = data.google_client_config.current.zone

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

  named_port {
    name = "http"
    port = 80
  }

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
    port = "80"
  }
}
