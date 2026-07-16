import functions_framework
import json
import re


@functions_framework.http
def validate_input(request):
    request_json = request.get_json(silent=True)

    if not request_json:
        return (json.dumps({"status": "error", "message": "No input data received"}), 400)

    email = request_json.get("email", "")
    name = request_json.get("name", "")

    email_pattern = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"

    if not name:
        return (json.dumps({"status": "error", "message": "name is required"}), 400)

    if not email or not re.match(email_pattern, email):
        return (json.dumps({"status": "error", "message": "a valid email is required"}), 400)

    return (json.dumps({"status": "success", "data": {"name": name, "email": email}}), 200)

# test comment
# second test comment