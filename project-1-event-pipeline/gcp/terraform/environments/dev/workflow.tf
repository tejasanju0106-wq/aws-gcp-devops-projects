resource "google_workflows_workflow" "job_pipeline" {
  name            = "job-pipeline"
  region          = var.region
  description     = "Orchestrates the user signup pipeline"
  source_contents = file("../../../workflows/job-pipeline.yaml")
}