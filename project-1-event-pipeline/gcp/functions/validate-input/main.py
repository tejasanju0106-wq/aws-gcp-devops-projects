import functions_framework
from flask import jsonify

@functions_framework.http
def validate_input(request):
    request_json = request.get_json(silent=True)

    if not request_json:
        return jsonify({"status": "error", "message": "No input data received"}), 400

    email = request_json.get("email", "")
    name = request_json.get("name", "")

    if not email or "@" not in email:
        return jsonify({"status": "error", "message": "Invalid or missing email"}), 400

    if not name:
        return jsonify({"status": "error", "message": "Missing name"}), 400

    return jsonify({
        "status": "success",
        "message": "Input validated successfully",
        "data": {"email": email, "name": name}
    }), 200# test comment
