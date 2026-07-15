# ============================================================
# validate-input
# ============================================================
data "archive_file" "validate_input_zip" {
  type        = "zip"
  source_dir  = "../../../functions/validate-input"
  output_path = "/tmp/validate-input.zip"
}

resource "google_storage_bucket_object" "validate_input_source" {
  name   = "validate-input-${data.archive_file.validate_input_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_artifacts.name
  source = data.archive_file.validate_input_zip.output_path
}

resource "google_cloudfunctions2_function" "validate_input" {
  name     = "validate-input"
  location = var.region

  build_config {
    runtime     = "python312"
    entry_point = "validate_input"
    source {
      storage_source {
        bucket = google_storage_bucket.function_artifacts.name
        object = google_storage_bucket_object.validate_input_source.name
      }
    }
  }

  service_config {
    available_memory      = "256M"
    timeout_seconds        = 60
    service_account_email  = google_service_account.validate_input.email
    ingress_settings        = "ALLOW_ALL"
  }
}

resource "google_cloudfunctions2_function_iam_member" "validate_input_invoker" {
  location       = var.region
  cloud_function = google_cloudfunctions2_function.validate_input.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

# ============================================================
# trigger-signup
# ============================================================
data "archive_file" "trigger_signup_zip" {
  type        = "zip"
  source_dir  = "../../../functions/trigger-signup"
  output_path = "/tmp/trigger-signup.zip"
}

resource "google_storage_bucket_object" "trigger_signup_source" {
  name   = "trigger-signup-${data.archive_file.trigger_signup_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_artifacts.name
  source = data.archive_file.trigger_signup_zip.output_path
}

resource "google_cloudfunctions2_function" "trigger_signup" {
  name     = "trigger-signup"
  location = var.region

  build_config {
    runtime     = "python312"
    entry_point = "trigger_signup"
    source {
      storage_source {
        bucket = google_storage_bucket.function_artifacts.name
        object = google_storage_bucket_object.trigger_signup_source.name
      }
    }
  }

  service_config {
    available_memory     = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.trigger_signup.email
    ingress_settings       = "ALLOW_ALL"
  }
}

resource "google_cloudfunctions2_function_iam_member" "trigger_signup_invoker" {
  location       = var.region
  cloud_function = google_cloudfunctions2_function.trigger_signup.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

# ============================================================
# get-job-status
# ============================================================
data "archive_file" "get_job_status_zip" {
  type        = "zip"
  source_dir  = "../../../functions/get-job-status"
  output_path = "/tmp/get-job-status.zip"
}

resource "google_storage_bucket_object" "get_job_status_source" {
  name   = "get-job-status-${data.archive_file.get_job_status_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_artifacts.name
  source = data.archive_file.get_job_status_zip.output_path
}

resource "google_cloudfunctions2_function" "get_job_status" {
  name     = "get-job-status"
  location = var.region

  build_config {
    runtime     = "python312"
    entry_point = "get_job_status"
    source {
      storage_source {
        bucket = google_storage_bucket.function_artifacts.name
        object = google_storage_bucket_object.get_job_status_source.name
      }
    }
  }

  service_config {
    available_memory     = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.get_job_status.email
    ingress_settings       = "ALLOW_ALL"
  }
}

resource "google_cloudfunctions2_function_iam_member" "get_job_status_invoker" {
  location       = var.region
  cloud_function = google_cloudfunctions2_function.get_job_status.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

# ============================================================
# retry-failed-jobs
# ============================================================
data "archive_file" "retry_failed_jobs_zip" {
  type        = "zip"
  source_dir  = "../../../functions/retry-failed-jobs"
  output_path = "/tmp/retry-failed-jobs.zip"
}

resource "google_storage_bucket_object" "retry_failed_jobs_source" {
  name   = "retry-failed-jobs-${data.archive_file.retry_failed_jobs_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_artifacts.name
  source = data.archive_file.retry_failed_jobs_zip.output_path
}

resource "google_cloudfunctions2_function" "retry_failed_jobs" {
  name     = "retry-failed-jobs"
  location = var.region

  build_config {
    runtime     = "python312"
    entry_point = "retry_failed_jobs"
    source {
      storage_source {
        bucket = google_storage_bucket.function_artifacts.name
        object = google_storage_bucket_object.retry_failed_jobs_source.name
      }
    }
  }

  service_config {
    available_memory     = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.retry_failed_jobs.email
    ingress_settings       = "ALLOW_ALL"
  }
}

resource "google_cloudfunctions2_function_iam_member" "retry_failed_jobs_invoker" {
  location       = var.region
  cloud_function = google_cloudfunctions2_function.retry_failed_jobs.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

# ============================================================
# consumer-notification
# ============================================================
data "archive_file" "consumer_notification_zip" {
  type        = "zip"
  source_dir  = "../../../functions/consumer-notification"
  output_path = "/tmp/consumer-notification.zip"
}

resource "google_storage_bucket_object" "consumer_notification_source" {
  name   = "consumer-notification-${data.archive_file.consumer_notification_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_artifacts.name
  source = data.archive_file.consumer_notification_zip.output_path
}

resource "google_cloudfunctions2_function" "consumer_notification" {
  name     = "consumer-notification"
  location = var.region

  build_config {
    runtime     = "python312"
    entry_point = "consumer_notification"
    source {
      storage_source {
        bucket = google_storage_bucket.function_artifacts.name
        object = google_storage_bucket_object.consumer_notification_source.name
      }
    }
  }

  service_config {
    available_memory     = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.consumer_notification.email
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.job_events.id
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
  }
}

# ============================================================
# consumer-audit
# ============================================================
data "archive_file" "consumer_audit_zip" {
  type        = "zip"
  source_dir  = "../../../functions/consumer-audit"
  output_path = "/tmp/consumer-audit.zip"
}

resource "google_storage_bucket_object" "consumer_audit_source" {
  name   = "consumer-audit-${data.archive_file.consumer_audit_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_artifacts.name
  source = data.archive_file.consumer_audit_zip.output_path
}

resource "google_cloudfunctions2_function" "consumer_audit" {
  name     = "consumer-audit"
  location = var.region

  build_config {
    runtime     = "python312"
    entry_point = "consumer_audit"
    source {
      storage_source {
        bucket = google_storage_bucket.function_artifacts.name
        object = google_storage_bucket_object.consumer_audit_source.name
      }
    }
  }

  service_config {
    available_memory     = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.consumer_audit.email
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.job_events.id
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
  }
}
# ============================================================
# finalizer (Firestore-triggered)
# ============================================================
data "archive_file" "finalizer_zip" {
  type        = "zip"
  source_dir  = "../../../functions/finalizer"
  output_path = "/tmp/finalizer.zip"
}

resource "google_storage_bucket_object" "finalizer_source" {
  name   = "finalizer-${data.archive_file.finalizer_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_artifacts.name
  source = data.archive_file.finalizer_zip.output_path
}

resource "google_cloudfunctions2_function" "finalizer" {
  name     = "finalizer"
  location = var.region

  build_config {
    runtime     = "python312"
    entry_point = "finalizer"
    source {
      storage_source {
        bucket = google_storage_bucket.function_artifacts.name
        object = google_storage_bucket_object.finalizer_source.name
      }
    }
  }

  service_config {
    available_memory     = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.finalizer.email
  }

  event_trigger {
    trigger_region        = var.region
    event_type            = "google.cloud.firestore.document.v1.written"
    retry_policy          = "RETRY_POLICY_DO_NOT_RETRY"
    service_account_email = google_service_account.finalizer.email

    event_filters {
      attribute = "database"
      value     = "(default)"
    }

    event_filters {
      attribute = "document"
      value     = "jobs/{jobId}/stages/{stageId}"
      operator  = "match-path-pattern"
    }
  }
}

# ============================================================
# handle-dlq (two functions, one shared codebase)
# ============================================================
data "archive_file" "handle_dlq_zip" {
  type        = "zip"
  source_dir  = "../../../functions/handle-dlq"
  output_path = "/tmp/handle-dlq.zip"
}

resource "google_storage_bucket_object" "handle_dlq_source" {
  name   = "handle-dlq-${data.archive_file.handle_dlq_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_artifacts.name
  source = data.archive_file.handle_dlq_zip.output_path
}

resource "google_cloudfunctions2_function" "handle_notification_dlq" {
  name     = "handle-notification-dlq"
  location = var.region

  build_config {
    runtime     = "python312"
    entry_point = "handle_notification_dlq"
    source {
      storage_source {
        bucket = google_storage_bucket.function_artifacts.name
        object = google_storage_bucket_object.handle_dlq_source.name
      }
    }
  }

  service_config {
    available_memory     = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.handle_dlq.email
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.notification_dlq.id
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
  }
}

resource "google_cloudfunctions2_function" "handle_audit_dlq" {
  name     = "handle-audit-dlq"
  location = var.region

  build_config {
    runtime     = "python312"
    entry_point = "handle_audit_dlq"
    source {
      storage_source {
        bucket = google_storage_bucket.function_artifacts.name
        object = google_storage_bucket_object.handle_dlq_source.name
      }
    }
  }

  service_config {
    available_memory     = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.handle_dlq.email
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.audit_dlq.id
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
  }
}