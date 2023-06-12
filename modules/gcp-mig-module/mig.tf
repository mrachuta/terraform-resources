locals {
  nginx_metadata = var.nginx_bucket_name != null ? {
    nginx_bucket_name = var.nginx_bucket_name
    ssl_enabled       = var.https_port != null ? "true" : "false"
  } : {}
}

data "google_compute_image" "mig_image" {
  count   = var.mig_image_family_link != null ? 1 : 0
  family  = split("/", var.mig_image_family_link)[5]
  project = split("/", var.mig_image_family_link)[1]
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
      foo = "bar"
    },
    var.mig_additional_labels
  )

  instance_description = var.mig_description
  machine_type         = var.mig_machine_type
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = coalesce(
      var.mig_specific_image_link,
      data.google_compute_image.mig_image[0].self_link
    )
    auto_delete = true
    boot        = true

    dynamic "disk_encryption_key" {
      for_each = var.mig_disk_encryption != null ? [1] : [0]
      content {
        kms_key_self_link = var.mig_disk_kms_key_path
      }
    }
  }

  # Main network
  network_interface {
    network = (
      var.create_network == true ?
      google_compute_network.vpc_network[0].name :
      var.network_name
    )
    subnetwork = (
      var.create_subnetwork == true ?
      google_compute_subnetwork.mig_subnetwork[0].name :
      var.subnetwork_name
    )
  }

  # Additional networks
  # for_each in dynamic block is using
  # block name as iterator; not eachs
  dynamic "network_interface" {
    for_each = var.additional_networks
    content {
      network    = network_interface.value.network_name
      subnetwork = network_interface.value.subnetwork_name
    }
  }

  metadata = merge(
    {
      enable-oslogin = "true"
    },
    local.nginx_metadata,
    var.mig_additional_metadata
  )

  metadata_startup_script = var.mig_startup_script

  service_account {
    email = var.mig_service_account_email
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
