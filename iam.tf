resource "google_project_iam_binding" "project" {
  project = var.project
  role    = "roles/bigquery.admin"

  members = [
    "serviceAccount:${google_service_account.bigquery-owner-sa.email}",
    "serviceAccount:${google_service_account.airbyte_sa.email}"
  ]
}