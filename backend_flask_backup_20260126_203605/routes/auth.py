from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token
from backend_flask.app import db
from backend_flask.models.models import User
from werkzeug.security import generate_password_hash, check_password_hash
import random

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/admin-register', methods=['POST'])
def admin_register():
    data = request.json
    email = data.get('email')
    password = data.get('password')
    full_name = data.get('full_name')
    phone = data.get('phone_number', '0000000000') # Default for admin if not provided

    if not email or not password:
        return jsonify({"msg": "Email and password required"}), 400
    
    if User.query.filter_by(email=email).first():
        return jsonify({"msg": "User already exists"}), 400
        
    new_user = User(
        email=email,
        full_name=full_name,
        phone_number=phone,
        password_hash=generate_password_hash(password),
        is_verified=True
    )
    
    db.session.add(new_user)
    db.session.commit()
    
    return jsonify({"msg": "Admin registered successfully"}), 201

@auth_bp.route('/admin-login', methods=['POST'])
def admin_login():
    data = request.json
    email = data.get('email')
    password = data.get('password')
    
    user = User.query.filter_by(email=email).first()
    
    if user and check_password_hash(user.password_hash, password):
        access_token = create_access_token(identity=user.phone_number)
        return jsonify(access_token=access_token, user={"name": user.full_name, "email": user.email}), 200
        
    return jsonify({"msg": "Invalid credentials"}), 401

@auth_bp.route('/request-otp', methods=['POST'])
def request_otp():
    data = request.json
    phone = data.get('phone_number')
    if not phone:
        return jsonify({"msg": "Phone number required"}), 400
    
    # In a real app, send OTP via SMS. For now, simulate.
    otp = "123456" 
    return jsonify({"msg": "OTP sent successfully", "otp": otp}), 200

@auth_bp.route('/verify-otp', methods=['POST'])
def verify_otp():
    data = request.json
    phone = data.get('phone_number')
    otp = data.get('otp')
    
    if otp == "123456": # Demo OTP
        # Check if user exists, else create
        # In a real app, you'd fetch user from DB
        access_token = create_access_token(identity=phone)
        return jsonify(access_token=access_token), 200
    
    return jsonify({"msg": "Invalid OTP"}), 401
