from flask import Blueprint, jsonify

auth = Blueprint("auth", __name__)

@auth.get("/test-auth")
def test_auth():
    return jsonify({"message": "Auth route works"})
