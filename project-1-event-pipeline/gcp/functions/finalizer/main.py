import functions_framework
from google.cloud import firestore
from cloudevents.http import CloudEvent

db = firestore.Client()

TERMINAL_STATES = {"COMPLETED", "FAILED"}


@functions_framework.cloud_event
def finalizer(cloud_event: CloudEvent):
    try:
        subject = cloud_event["subject"]
        print(f"DEBUG: finalizer triggered by subject: {subject}")

        parts = subject.split("/")
        job_id = parts[2]

        print(f"DEBUG: extracted jobId={job_id}")

        job_ref = db.collection("jobs").document(job_id)
        notification_ref = job_ref.collection("stages").document("notification")
        audit_ref = job_ref.collection("stages").document("audit")

        notification_doc = notification_ref.get()
        audit_doc = audit_ref.get()

        if not notification_doc.exists or not audit_doc.exists:
            print(f"DEBUG: one or both stages don't exist yet for job {job_id}, exiting")
            return "OK"

        notification_status = notification_doc.to_dict().get("status")
        audit_status = audit_doc.to_dict().get("status")

        print(f"DEBUG: notification={notification_status}, audit={audit_status}")

        if notification_status not in TERMINAL_STATES or audit_status not in TERMINAL_STATES:
            print(f"DEBUG: not both terminal yet for job {job_id}, exiting")
            return "OK"

        if notification_status == "COMPLETED" and audit_status == "COMPLETED":
            overall_status = "COMPLETED"
        elif notification_status == "FAILED" and audit_status == "FAILED":
            overall_status = "FAILED"
        else:
            overall_status = "PARTIAL_FAILED"

        job_ref.update({
            "overallStatus": overall_status,
        })

        print(f"DEBUG: job {job_id} finalized as {overall_status}")

        return "OK"

    except Exception as e:
        print(f"FATAL ERROR in finalizer: {type(e).__name__}: {str(e)}")
        raise