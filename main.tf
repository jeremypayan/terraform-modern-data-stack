terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.59.0"
    }
  }
}

provider "google" {
  credentials = file("terraform-infra-380516.json")

  project = var.project
  region  = var.region
  zone    = var.zone
}

