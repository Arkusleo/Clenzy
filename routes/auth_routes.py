from flask import Blueprint, request, jsonify
from core.database import get_connection
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token

auth = Blueprint("auth", __name__)

@auth.route('/admin-register', methods=['POST'])
def admin_register():
    data = request.json
    email = data.get('email')
    password = data.get('password')
    full_name = data.get('full_name')
    phone = data.get('phone_number', '0000000000')

    if not email or not password:
        return jsonify({"msg": "Email and password required"}), 400

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        # Check if user exists
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        if cursor.fetchone():
            return jsonify({"msg": "User already exists"}), 400

        hashed_pw = generate_password_hash(password)
        
        # Insert new user
        query = """INSERT INTO users (email, full_name, phone_number, password_hash, is_verified) 
                   VALUES (%s, %s, %s, %s, %s)"""
        cursor.execute(query, (email, full_name, phone, hashed_pw, True))
        conn.commit()
        
        return jsonify({"msg": "Admin registered successfully"}), 201
    except Exception as e:
        return jsonify({"msg": f"Error: {str(e)}"}), 500
    finally:
        cursor.close()
        conn.close()

@auth.route('/admin-login', methods=['POST'])
def admin_login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()

        if user and check_password_hash(user['password_hash'], password):
            access_token = create_access_token(identity=user['phone_number'])
            return jsonify(access_token=access_token, user={"name": user['full_name'], "email": user['email']}), 200
        
        return jsonify({"msg": "Invalid credentials"}), 401
    except Exception as e:
        return jsonify({"msg": f"Error: {str(e)}"}), 500
    finally:
        cursor.close()
        conn.close()

@auth.get("/test-auth")
def test_auth():
    return jsonify({"message": "Auth route works"})
