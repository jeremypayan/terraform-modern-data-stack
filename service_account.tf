# BigQuery Owner service account 
resource "google_service_account" "bigquery-owner-sa" {
  account_id   = "bigquery-owner-sa"
  project      = var.project
  display_name = "service account to manage BigQuery resources"
  description  = "service account to manage BigQuery resources"
}

# BigQuery Owner account key
resource "google_service_account_key" "bigquery-owner-sa-key" {
  service_account_id = google_service_account.bigquery-owner-sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# Airbyte service account
resource "google_service_account" "airbyte_sa" {
  account_id   = "airbyte"
  project      = var.project
  display_name = "Airbyte Service Account"
  description  = "Airbyte service account"
}

# Airbyte service account key
resource "google_service_account_key" "airbyte_sa_key" {
  service_account_id = google_service_account.airbyte_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}