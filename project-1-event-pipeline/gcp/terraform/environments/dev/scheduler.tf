resource "google_cloud_scheduler_job" "retry_failed_jobs_schedule" {
  name      = "retry-failed-jobs-schedule"
  region    = var.region
  schedule  = "*/15 * * * *"
  time_zone = "Etc/UTC"

  retry_config {
    retry_count          = 0
    max_retry_duration   = "0s"
    min_backoff_duration = "5s"
    max_backoff_duration = "3600s"
    max_doublings        = 5
  }

  http_target {
    uri         = "https://us-central1-devops-learning-p1-teja.cloudfunctions.net/retry-failed-jobs"
    http_method = "POST"
    body        = base64encode("{}")
    headers = {
      "Content-Type" = "application/json"
    }
  }
}