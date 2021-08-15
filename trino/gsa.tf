
# Service Account - Agent
resource "google_service_account" "trino" {
  account_id   = "trino-gsa"
  display_name = "Trino Node Service Account"
  description  = "Service Account used by Trino Nodes"
}

# Grant the service account the minimum necessary roles and permissions in order to run the GKE cluster
resource "google_project_iam_member" "log_writer" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.trino.email}"
}

resource "google_project_iam_member" "metric_writer" {
  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.trino.email}"
}

resource "google_project_iam_member" "monitoring_viewer" {
  role   = "roles/monitoring.viewer"
  member = "serviceAccount:${google_service_account.trino.email}"
}