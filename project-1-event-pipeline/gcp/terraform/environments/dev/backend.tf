terraform {
  backend "gcs" {
    bucket = "devops-learning-p1-teja-tfstate"
    prefix = "environments/dev"
  }
}