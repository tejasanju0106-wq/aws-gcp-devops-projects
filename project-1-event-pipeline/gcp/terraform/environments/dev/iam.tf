resource "google_service_account" "trigger_signup" {
  account_id   = "sa-trigger-signup"
  display_name = "trigger-signup function"
}

resource "google_service_account" "get_job_status" {
  account_id   = "sa-get-job-status"
  display_name = "get-job-status function"
}

resource "google_service_account" "validate_input" {
  account_id   = "sa-validate-input"
  display_name = "validate-input function"
}

resource "google_service_account" "consumer_notification" {
  account_id   = "sa-consumer-notification"
  display_name = "consumer-notification function"
}

resource "google_service_account" "consumer_audit" {
  account_id   = "sa-consumer-audit"
  display_name = "consumer-audit function"
}

resource "google_service_account" "handle_dlq" {
  account_id   = "sa-handle-dlq"
  display_name = "handle-dlq functions"
}

resource "google_service_account" "finalizer" {
  account_id   = "sa-finalizer"
  display_name = "finalizer function"
}

resource "google_service_account" "retry_failed_jobs" {
  account_id   = "sa-retry-failed-jobs"
  display_name = "retry-failed-jobs function"
}

resource "google_service_account" "frontend" {
  account_id   = "sa-frontend"
  display_name = "signup-frontend Cloud Run service"
}