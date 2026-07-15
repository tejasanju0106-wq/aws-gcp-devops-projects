resource "google_secret_manager_secret" "email_api_key" {
  secret_id = "email-provider-api-key"

  replication {
    auto {}
  }
}