import functions_framework
import json
from google.cloud import firestore

db = firestore.Client()


@functions_framework.http
def get_job_status(request):
    headers = {"Access-Control-Allow-Origin": "*"}

    if request.method == "OPTIONS":
        headers.update({
            "Access-Control-Allow-Methods": "GET",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Max-Age": "3600",
        })
        return ("", 204, headers)

    job_id = request.args.get("jobId")
    if not job_id:
        return (json.dumps({"status": "error", "message": "jobId query parameter is required"}), 400, headers)

    job_ref = db.collection("jobs").document(job_id)
    job_doc = job_ref.get()

    if not job_doc.exists:
        return (json.dumps({"status": "error", "message": "No job found with that ID"}), 404, headers)

    job_data = job_doc.to_dict()

    stages = {}
    for stage_name in ["notification", "audit"]:
        stage_doc = job_ref.collection("stages").document(stage_name).get()
        if stage_doc.exists:
            stage_data = stage_doc.to_dict()
            stages[stage_name] = stage_data.get("status", "UNKNOWN")
        else:
            stages[stage_name] = "PENDING"

    response = {
        "status": "success",
        "jobId": job_id,
        "overallStatus": job_data.get("overallStatus"),
        "stages": stages,
        "createdAt": job_data.get("createdAt"),
    }

    return (json.dumps(response), 200, headers)