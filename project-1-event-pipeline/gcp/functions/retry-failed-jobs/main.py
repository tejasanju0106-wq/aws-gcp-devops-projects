import functions_framework
import json
from google.cloud import firestore
from google.cloud.workflows import executions_v1
from google.cloud.workflows.executions_v1 import Execution

db = firestore.Client()
execution_client = executions_v1.ExecutionsClient()

PROJECT_ID = "devops-learning-p1-teja"
LOCATION = "us-central1"
WORKFLOW_NAME = "user-signup-workflow"

RETRYABLE_STATUSES = ["FAILED", "PARTIAL_FAILED"]


@functions_framework.http
def retry_failed_jobs(request):
    jobs_ref = db.collection("jobs")
    query = jobs_ref.where("overallStatus", "in", RETRYABLE_STATUSES)
    failed_jobs = query.stream()

    retried_count = 0
    results = []

    for job_doc in failed_jobs:
        job_data = job_doc.to_dict()
        job_id = job_data.get("jobId")
        email = job_data.get("email")
        name = job_data.get("name")
        retry_count = job_data.get("retryCount", 0)

        print(f"DEBUG: found retryable job {job_id}, current status={job_data.get('overallStatus')}, retryCount={retry_count}")

        if retry_count >= 3:
            print(f"DEBUG: job {job_id} has already been retried {retry_count} times, skipping")
            continue

        parent = f"projects/{PROJECT_ID}/locations/{LOCATION}/workflows/{WORKFLOW_NAME}"
        workflow_input = json.dumps({"jobId": job_id, "email": email, "name": name})
        execution = Execution(argument=workflow_input)

        try:
            created_execution = execution_client.create_execution(parent=parent, execution=execution)
            execution_id = created_execution.name.split("/")[-1]

            job_doc.reference.update({
                "overallStatus": "RECEIVED",
                "workflowExecutionId": execution_id,
                "retryCount": retry_count + 1,
            })

            print(f"DEBUG: restarted workflow for job {job_id}, new execution={execution_id}")
            retried_count += 1
            results.append({"jobId": job_id, "status": "retried"})

        except Exception as e:
            print(f"ERROR: failed to retry job {job_id}: {str(e)}")
            results.append({"jobId": job_id, "status": "retry_failed", "error": str(e)})

    print(f"DEBUG: retry-failed-jobs completed, retried {retried_count} job(s)")

    return (json.dumps({"status": "success", "retriedCount": retried_count, "results": results}), 200)