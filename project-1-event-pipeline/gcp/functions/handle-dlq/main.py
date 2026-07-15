import base64
import json
import functions_framework
from google.cloud import firestore

db = firestore.Client()


def _handle_failure(cloud_event, stage_name):
    try:
        data = cloud_event.data["message"]["data"]
        message_json = base64.b64decode(data).decode("utf-8")
        message = json.loads(message_json)

        job_id = message.get("jobId")
        email = message.get("email", "unknown")

        print(f"DEBUG: handle-dlq triggered for stage={stage_name}, jobId={job_id}")

        if not job_id:
            print("ERROR: No jobId in DLQ message, cannot mark stage as failed")
            return "OK"

        stage_ref = db.collection("jobs").document(job_id).collection("stages").document(stage_name)
        stage_ref.set({
            "status": "FAILED",
            "startedAt": firestore.SERVER_TIMESTAMP,
            "completedAt": firestore.SERVER_TIMESTAMP,
            "errorMessage": f"Message exceeded max delivery attempts and landed in {stage_name}-dlq-topic",
        })

        print(f"ALERT: job {job_id} stage {stage_name} marked FAILED after exhausting retries (email: {email})")

        return "OK"

    except Exception as e:
        print(f"FATAL ERROR in handle-dlq ({stage_name}): {type(e).__name__}: {str(e)}")
        raise


@functions_framework.cloud_event
def handle_notification_dlq(cloud_event):
    return _handle_failure(cloud_event, "notification")


@functions_framework.cloud_event
def handle_audit_dlq(cloud_event):
    return _handle_failure(cloud_event, "audit")