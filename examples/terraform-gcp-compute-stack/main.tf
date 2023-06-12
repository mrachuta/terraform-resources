module "gcp_webserver_bucket" {
  source = "../../modules/gcp-webserver-bucket-module"

  bucket_name         = "test-stack-nginx-bucket"
  bucket_region       = "us-central1"
  bucket_encryption   = true
  bucket_kms_key_path = "projects/kr-free-2023/locations/us-central1/keyRings/kr-free-2003-keyring/cryptoKeys/cloudStorageKey"
  site_name           = "mysite.com"
  http_port           = 8080
  https_port          = 8443
  generate_cert       = true
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

module "gcp_mig" {
  source = "../../modules/gcp-mig-module"

  project_name              = "kr-free-2023"
  mig_region                = "us-central1"
  mig_zone                  = "us-central1-b"
  mig_service_account_email = "test-stack-sa@kr-free-2023.iam.gserviceaccount.com"
  mig_name                  = "test-stack"
  mig_description           = "MIG with machines running nginx"
  mig_size                  = 2
  mig_disk_encryption       = true
  mig_disk_kms_key_path     = "projects/kr-free-2023/locations/us-central1/keyRings/kr-free-2003-keyring/cryptoKeys/computeEngineKey"
  nginx_bucket_name         = module.gcp_webserver_bucket.bucket_name_output
  site_name                 = module.gcp_webserver_bucket.site_name_output
  http_port                 = module.gcp_webserver_bucket.http_port_output
  https_port                = module.gcp_webserver_bucket.https_port_output

  mig_additional_labels = {
    test = "true"
  }

  mig_startup_script = <<EOF
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
      mkdir /var/www/html/${module.gcp_webserver_bucket.site_name_output}
      gsutil cp -R gs://${module.gcp_webserver_bucket.bucket_name_output}/*.{html,htm} /var/www/html/${module.gcp_webserver_bucket.site_name_output}/
      gsutil cp -R gs://${module.gcp_webserver_bucket.bucket_name_output}/custom.conf /etc/nginx/sites-available/custom.conf
      gsutil cp -R gs://${module.gcp_webserver_bucket.bucket_name_output}/nginx.conf /etc/nginx/nginx.conf
      chown -R www-data:www-data /var/www/html/${module.gcp_webserver_bucket.site_name_output}
      chown www-data:www-data /etc/nginx/sites-available/custom.conf /etc/nginx/nginx.conf
      ssl_enabled=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/ssl_enabled" -H "Metadata-Flavor: Google")
      if [ "$ssl_enabled" == 'true' ]; then
        echo 'ssl_enabled flag found...'
        mkdir /etc/ssl/${module.gcp_webserver_bucket.site_name_output}
        gsutil cp -R gs://${module.gcp_webserver_bucket.bucket_name_output}/*.{crt,key} /etc/ssl/${module.gcp_webserver_bucket.site_name_output}/
        chown -R www-data:www-data /etc/ssl/${module.gcp_webserver_bucket.site_name_output}
      fi
      ln -s /etc/nginx/sites-available/custom.conf /etc/nginx/sites-enabled/custom.conf
      rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default
    fi
    sudo systemctl enable --now nginx
    sudo systemctl restart nginx
    EOF

  create_network    = true
  network_name      = "test-network"
  create_subnetwork = true
  subnetwork_name   = "subnet-mig-01"
}

module "gcp_lb" {
  source = "../../modules/gcp-tcp-loadbalancer-module"

  lb_region    = "us-central1"
  lb_name      = "test-stack-lb"
  external_lb  = true
  mig_name     = module.gcp_mig.instance_group_output
  network_name = module.gcp_mig.network_name_output
  http_port    = module.gcp_mig.http_port_output
  https_port   = module.gcp_mig.https_port_output
}
