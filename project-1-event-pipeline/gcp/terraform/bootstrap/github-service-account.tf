resource "google_service_account" "github_actions" {
  account_id   = "github-actions-deployer"
  display_name = "GitHub Actions Deployer"
  description  = "Used by GitHub Actions to deploy resources via Workload Identity Federation"
}
resource "google_project_iam_member" "github_actions_editor" {
  project = "devops-learning-p1-teja"
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}
resource "google_service_account_iam_member" "github_workload_identity_binding" {
  service_account_id = google_service_account.github_actions.name
  role                = "roles/iam.workloadIdentityUser"
  member              = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/tejasanju0106-wq/aws-gcp-devops-projects"
}