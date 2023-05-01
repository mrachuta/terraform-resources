variable "bucket_region" {
  type    = string
  default = "us-central1"
}

variable "bucket_name" {
  type    = string
  default = "example-bucket"
}

variable "bucket_encryption" {
  type    = bool
  default = false
}

variable "bucket_kms_key_path" {
  type    = string
  default = null
}

variable "http_port" {
  type    = number
  default = 80
}

variable "https_port" {
  type    = number
  default = null
}

variable "generate_cert" {
  type    = bool
  default = false
}

variable "additional_dns_names" {
  type    = list(string)
  default = []
}

variable "site_name" {
  type    = string
  default = "example.com"
}

variable "additional_bucket_files" {
  type = map(object(
    {
      bucket_file_name    = string
      bucket_file_content = string
    }
  ))
}
