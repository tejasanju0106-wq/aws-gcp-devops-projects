resource "google_storage_bucket" "function_artifacts" {
  name     = "devops-learning-p1-teja-function-artifacts"
  location = "US"

  uniform_bucket_level_access = true
}