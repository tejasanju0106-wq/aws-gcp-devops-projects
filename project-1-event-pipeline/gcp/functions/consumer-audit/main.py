import base64
import json
import functions_framework
from datetime import datetime, timezone
from google.cloud import firestore

db = firestore.Client()


@functions_framework.cloud_event
def consumer_audit(cloud_event):
    try:
        data = cloud_event.data["message"]["data"]
        message_json = base64.b64decode(data).decode("utf-8")
        message = json.loads(message_json)

        job_id = message.get("jobId")
        email = message.get("email", "unknown")
        name = message.get("name", "unknown")

        print(f"DEBUG: received message with jobId={job_id}, email={email}, name={name}")

        if not job_id:
            print("ERROR: No jobId in message, cannot track stage status")
            return "OK"

        stage_ref = db.collection("jobs").document(job_id).collection("stages").document("audit")
        existing = stage_ref.get()

        if existing.exists and existing.to_dict().get("status") == "COMPLETED":
            print(f"Job {job_id} audit already COMPLETED, skipping (idempotency)")
            return "OK"

        timestamp = datetime.now(timezone.utc).isoformat()
        print(f"AUDIT LOG: user '{name}' ({email}) signed up at {timestamp}")

        db.collection("audit_logs").add({
            "jobId": job_id,
            "name": name,
            "email": email,
            "signedUpAt": timestamp,
        })

        stage_ref.set({
            "status": "COMPLETED",
            "startedAt": firestore.SERVER_TIMESTAMP,
            "completedAt": firestore.SERVER_TIMESTAMP,
            "errorMessage": None,
        })

        print(f"DEBUG: Firestore write completed successfully for job {job_id}")

        return "OK"

    except Exception as e:
        print(f"FATAL ERROR in consumer_audit: {type(e).__name__}: {str(e)}")
        raise