import os
from flask import Flask, render_template
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_socketio import SocketIO
from dotenv import load_dotenv

load_dotenv()

db = SQLAlchemy()
jwt = JWTManager()
socketio = SocketIO(cors_allowed_origins="*")

import time

def create_app():
    app = Flask(__name__)
    
    # Configuration
    db_url = os.getenv('DATABASE_URL')
    if not db_url:
        print("ℹ️ No DATABASE_URL found. Falling back to local SQLite.")
        db_url = 'sqlite:///' + os.path.join(os.getcwd(), 'clenzy_test.db')
    
    app.config['SQLALCHEMY_DATABASE_URI'] = db_url
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'clenzy-super-secret-key')
    
    # Initialize Extensions
    try:
        db.init_app(app)
    except Exception as e:
        print(f"⚠️ Initial DB initialization failed: {e}. Trying SQLite fallback.")
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(os.getcwd(), 'clenzy_test.db')
        db.init_app(app)

    jwt.init_app(app)
    # Browsers block wildcard origin with credentials. Since we use Bearer headers, we can drop credentials for dev.
    CORS(app, resources={r"/*": {"origins": "*"}})
    socketio.init_app(app)
    
    # Register Blueprints
    from backend_flask.routes.auth import auth_bp
    from backend_flask.routes.bookings import bookings_bp
    from backend_flask.routes.workers import workers_bp
    from backend_flask.routes.panic import panic_bp
    from backend_flask.routes.users import users_bp
    
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(bookings_bp, url_prefix='/api/bookings')
    app.register_blueprint(workers_bp, url_prefix='/api/workers')
    app.register_blueprint(panic_bp, url_prefix='/api/panic')
    app.register_blueprint(users_bp, url_prefix='/api/users')
    
    @app.route('/')
    def index():
        return render_template('index.html')

    @app.route('/health')
    def health():
        return {"status": "healthy", "service": "clenzy-backend"}, 200

    return app
