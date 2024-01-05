variable "project_name" {
  type    = string
  default = "myproject"
}

variable "db_region" {
  type    = string
  default = "us-central1"
}

variable "db_instance_name" {
  type    = string
  default = "my-db-instance"
}

variable "db_version" {
  type    = string
  default = "POSTGRES_14"
}

variable "db_names" {
  type = map(string)
  default = {
    db1 = "my-db-instance"
  }
}

variable "db_users" {
  type = map(object(
    {
      user = string
      type = string
    }
  ))
  default = {}
}

variable "db_instance_size" {
  type    = string
  default = "db-g1-small"
}

variable "db_deletion_protection" {
  type    = bool
  default = true
}

variable "db_encryption" {
  type    = bool
  default = false
}

variable "db_kms_key_path" {
  type    = string
  default = null
}

variable "network_name" {
  type    = string
  default = "example-network"
}
