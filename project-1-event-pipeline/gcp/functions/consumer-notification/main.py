import base64
import json
import functions_framework
from google.cloud import firestore
from google.cloud import secretmanager

db = firestore.Client()
secret_client = secretmanager.SecretManagerServiceClient()

PROJECT_ID = "devops-learning-p1-teja"


def get_email_api_key():
    secret_path = f"projects/{PROJECT_ID}/secrets/email-provider-api-key/versions/latest"
    response = secret_client.access_secret_version(name=secret_path)
    return response.payload.data.decode("UTF-8")


@functions_framework.cloud_event
def consumer_notification(cloud_event):
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

        stage_ref = db.collection("jobs").document(job_id).collection("stages").document("notification")
        existing = stage_ref.get()

        if existing.exists and existing.to_dict().get("status") == "COMPLETED":
            print(f"Job {job_id} notification already COMPLETED, skipping (idempotency)")
            return "OK"

        api_key = get_email_api_key()
        print(f"DEBUG: fetched email provider API key (first 4 chars: {api_key[:4]}...)")
        print(f"Sending welcome email to {name} ({email})")

        stage_ref.set({
            "status": "COMPLETED",
            "startedAt": firestore.SERVER_TIMESTAMP,
            "completedAt": firestore.SERVER_TIMESTAMP,
            "errorMessage": None,
        })

        print(f"DEBUG: Firestore write completed successfully for job {job_id}")

        return "OK"

    except Exception as e:
        print(f"FATAL ERROR in consumer_notification: {type(e).__name__}: {str(e)}")
        raise