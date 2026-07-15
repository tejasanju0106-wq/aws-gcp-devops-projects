# trigger-signup: Firestore write + Workflows invoker
resource "google_project_iam_member" "trigger_signup_datastore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.trigger_signup.email}"
}

resource "google_project_iam_member" "trigger_signup_workflows" {
  project = var.project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.trigger_signup.email}"
}

# get-job-status: Firestore read-only
resource "google_project_iam_member" "get_job_status_datastore" {
  project = var.project_id
  role    = "roles/datastore.viewer"
  member  = "serviceAccount:${google_service_account.get_job_status.email}"
}

# validate-input: no extra roles needed

# consumer-notification: Firestore write + Secret Manager access + Eventarc + Run invoker
resource "google_project_iam_member" "consumer_notification_datastore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.consumer_notification.email}"
}

resource "google_project_iam_member" "consumer_notification_eventarc" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.consumer_notification.email}"
}

resource "google_secret_manager_secret_iam_member" "consumer_notification_secret" {
  secret_id = "email-provider-api-key"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.consumer_notification.email}"
}

resource "google_cloud_run_service_iam_member" "consumer_notification_run_invoker" {
  service  = "consumer-notification"
  location = var.region
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.consumer_notification.email}"
}

# consumer-audit: Firestore write + Eventarc + Run invoker
resource "google_project_iam_member" "consumer_audit_datastore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.consumer_audit.email}"
}

resource "google_project_iam_member" "consumer_audit_eventarc" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.consumer_audit.email}"
}

resource "google_cloud_run_service_iam_member" "consumer_audit_run_invoker" {
  service  = "consumer-audit"
  location = var.region
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.consumer_audit.email}"
}

# handle-dlq: Firestore write + Eventarc + Run invoker (both DLQ functions)
resource "google_project_iam_member" "handle_dlq_datastore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.handle_dlq.email}"
}

resource "google_project_iam_member" "handle_dlq_eventarc" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.handle_dlq.email}"
}

resource "google_cloud_run_service_iam_member" "handle_notification_dlq_run_invoker" {
  service  = "handle-notification-dlq"
  location = var.region
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.handle_dlq.email}"
}

resource "google_cloud_run_service_iam_member" "handle_audit_dlq_run_invoker" {
  service  = "handle-audit-dlq"
  location = var.region
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.handle_dlq.email}"
}

# finalizer: Firestore write + Eventarc + Run invoker
resource "google_project_iam_member" "finalizer_datastore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.finalizer.email}"
}

resource "google_project_iam_member" "finalizer_eventarc" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.finalizer.email}"
}

resource "google_cloud_run_service_iam_member" "finalizer_run_invoker" {
  service  = "finalizer"
  location = var.region
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.finalizer.email}"
}

# retry-failed-jobs: Firestore write + Workflows invoker
resource "google_project_iam_member" "retry_failed_jobs_datastore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.retry_failed_jobs.email}"
}

resource "google_project_iam_member" "retry_failed_jobs_workflows" {
  project = var.project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.retry_failed_jobs.email}"
}

# frontend: no extra roles needed