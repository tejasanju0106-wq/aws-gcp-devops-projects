import functions_framework
import json
import uuid
from datetime import datetime, timezone
from google.cloud import firestore
from google.cloud.workflows import executions_v1
from google.cloud.workflows.executions_v1 import Execution

db = firestore.Client()
execution_client = executions_v1.ExecutionsClient()

PROJECT_ID = "devops-learning-p1-teja"
LOCATION = "us-central1"
WORKFLOW_NAME = "user-signup-workflow"


@functions_framework.http
def trigger_signup(request):
    headers = {"Access-Control-Allow-Origin": "*"}

    if request.method == "OPTIONS":
        headers.update({
            "Access-Control-Allow-Methods": "POST",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Max-Age": "3600",
        })
        return ("", 204, headers)

    request_json = request.get_json(silent=True)
    if not request_json:
        return (json.dumps({"status": "error", "message": "No input data received"}), 400, headers)

    email = request_json.get("email", "")
    name = request_json.get("name", "")

    if not email or not name:
        return (json.dumps({"status": "error", "message": "email and name are required"}), 400, headers)

    job_id = str(uuid.uuid4())

    job_ref = db.collection("jobs").document(job_id)
    job_ref.set({
        "jobId": job_id,
        "name": name,
        "email": email,
        "overallStatus": "RECEIVED",
        "createdAt": datetime.now(timezone.utc).isoformat(),
        "updatedAt": datetime.now(timezone.utc).isoformat(),
        "workflowExecutionId": None,
        "errorMessage": None,
        "retryCount": 0,
    })

    parent = f"projects/{PROJECT_ID}/locations/{LOCATION}/workflows/{WORKFLOW_NAME}"
    workflow_input = json.dumps({"jobId": job_id, "email": email, "name": name})
    execution = Execution(argument=workflow_input)

    try:
        created_execution = execution_client.create_execution(parent=parent, execution=execution)
        execution_id = created_execution.name.split("/")[-1]
        job_ref.update({"workflowExecutionId": execution_id})
    except Exception as e:
        job_ref.update({"overallStatus": "FAILED", "errorMessage": str(e)})
        return (json.dumps({"status": "error", "message": "Failed to start workflow"}), 500, headers)

    return (json.dumps({"status": "success", "jobId": job_id}), 200, headers)