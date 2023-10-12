output "bigquery-owner-sa-key" {
  value     = google_service_account_key.bigquery-owner-sa-key.private_key
  sensitive = true
}