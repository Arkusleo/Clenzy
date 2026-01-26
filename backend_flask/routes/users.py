from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from backend_flask.app import db
from backend_flask.models.models import User
from backend_flask.utils.responses import success_response, error_response

users_bp = Blueprint('users', __name__)

@users_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    phone = get_jwt_identity()
    user = User.query.filter_by(phone_number=phone).first()
    
    if not user:
        return error_response("User not found", 404)
        
    return success_response({
        "full_name": user.full_name,
        "email": user.email,
        "phone_number": user.phone_number,
        "is_verified": user.is_verified,
        "gender": user.gender
    })

@users_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    phone = get_jwt_identity()
    user = User.query.filter_by(phone_number=phone).first()
    
    if not user:
        return error_response("User not found", 404)
        
    data = request.json
    user.full_name = data.get('full_name', user.full_name)
    user.email = data.get('email', user.email)
    user.gender = data.get('gender', user.gender)
    
    try:
        db.session.commit()
        return success_response(None, "Profile updated successfully")
    except Exception as e:
        db.session.rollback()
        return error_response(str(e), 500)
