resource "google_bigquery_dataset" "dbp_domain_marketing" {
  project       = var.project
  dataset_id    = "dbp_domain_marketing"
  friendly_name = "All the data for the marketing domain. Complex domains will have multiple base datasets"
  location      = var.bq_region
}

