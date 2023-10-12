variable "project" {}

variable "region" {
  default = "europe-west9"
}

variable "zone" {}

variable "airbyte_machine_type" {
  default = "e2-medium"
}

variable "bq_region" {
  default = "europe-west1"
}

variable "folder_id" {
  default = "cityscot.eu"

}

variable "billing_id" {

}

variable "catalog_project" {
  default = "central-catalog"

}