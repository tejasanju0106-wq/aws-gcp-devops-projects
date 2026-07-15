resource "google_pubsub_topic" "job_events" {
  name = "job-events"
}

resource "google_pubsub_topic" "notification_dlq" {
  name = "notification-dlq-topic"
}

resource "google_pubsub_topic" "audit_dlq" {
  name = "audit-dlq-topic"
}

resource "google_pubsub_subscription" "notification_sub" {
  name  = "notification-sub"
  topic = google_pubsub_topic.job_events.name

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.notification_dlq.id
    max_delivery_attempts = 5
  }
}

resource "google_pubsub_subscription" "audit_sub" {
  name  = "audit-sub"
  topic = google_pubsub_topic.job_events.name

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.audit_dlq.id
    max_delivery_attempts = 5
  }
}