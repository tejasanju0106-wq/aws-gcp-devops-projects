resource "google_cloud_run_v2_service" "signup_frontend" {
  name     = "signup-frontend"
  location = var.region

  template {
    service_account = google_service_account.frontend.email
    containers {
      image = "us-central1-docker.pkg.dev/devops-learning-p1-teja/frontend-images/signup-frontend:v1"
    }
  }

  lifecycle {
    ignore_changes = [template[0].containers[0].image]
  }
}

resource "google_cloud_run_v2_service_iam_member" "signup_frontend_invoker" {
  location = var.region
  name     = google_cloud_run_v2_service.signup_frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}