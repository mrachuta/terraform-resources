module "gcp_webserver_bucket" {
  source = "../modules/gcp-webserver-bucket-module"

  bucket_name          = "test-stack-nginx-bucket"
  bucket_region        = "us-central1"
  bucket_encryption    = true
  bucket_kms_key_path  = "projects/kr-free-2023/locations/us-central1/keyRings/kr-free-2003-keyring/cryptoKeys/cloudStorageKey"

  site_name            = "mysite.com"
  http_port            = 8080
  https_port           = 8443
  generate_cert        = true
  additional_dns_names = [
    "www.mysite.co.uk",
    "mysite.co.uk"
  ]

  additional_bucket_files = {
    "index" = {
      bucket_file_name    = "index.html"
      bucket_file_content = "<h1>Hello World!</h2>"
    },
    "file2" = {
      bucket_file_name    = "index2.html"
      bucket_file_content = "<a href=\"https://www.allegro.pl\">Visit allegro.pl</a>"
    },
    "file3" = {
      bucket_file_name    = "index3.html"
      bucket_file_content = "<p style=\"font-size:45px;color:red\">T E S T</p>"
    }
  }
}

module "gcp_webserver_mig" {
  source = "../modules/gcp-webserver-mig-module"

  project_name                    = "kr-free-2023"
  mig_region                      = "us-central1"
  mig_zone                        = "us-central1-b"
  mig_service_account_id          = "test-stack-sa"
  mig_service_account_description = "Service Account used to manage test-stack MIGs"
  mig_name                        = "test-stack"
  mig_description                 = "MIG with machines running nginx"
  mig_size                        = 2
  mig_disk_encryption             = true
  mig_disk_kms_key_path           = "projects/kr-free-2023/locations/us-central1/keyRings/kr-free-2003-keyring/cryptoKeys/computeEngineKey"
  nginx_bucket_name               = module.gcp_webserver_bucket.bucket_name_output
  site_name                       = module.gcp_webserver_bucket.site_name_output
  http_port                       = 8080
  https_port                      = 8443

  mig_additional_labels = {
    test    = "true"
  }

  network_name = "test-network"

  depends_on = [
    module.gcp_webserver_bucket
  ]
}

module "gcp_lb" {

  source = "../modules/gcp-loadbalancer-module"

  lb_region    = "us-central1"
  lb_name      = "test-stack-lb"
  mig_name     = module.gcp_webserver_mig.instance_group_output
  network_name = module.gcp_webserver_mig.network_name_output
  http_port    = 8080
  https_port   = 8443

  depends_on = [
    module.gcp_webserver_mig
  ]
}
