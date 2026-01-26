from flask import Blueprint, jsonify

users = Blueprint("users", __name__)

@users.get("/test-user")
def test_user():
    return jsonify({"message": "User route works"})
