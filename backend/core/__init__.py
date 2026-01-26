from flask import Flask, render_template
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_socketio import SocketIO
from config import Config

db = SQLAlchemy()
jwt = JWTManager()
socketio = SocketIO(cors_allowed_origins="*")

def create_app(config_class=Config):
    app = Flask(__name__, template_folder='../templates')
    app.config.from_object(config_class)

    # Initialize Extensions
    db.init_app(app)
    jwt.init_app(app)
    CORS(app, supports_credentials=True, resources={r"/*": {"origins": "*"}})
    socketio.init_app(app)

    with app.app_context():
        try:
            # Imports assuming backend/ is the root
            from routes.auth import auth_bp
            from routes.bookings import bookings_bp
            from routes.workers import workers_bp
            from routes.panic import panic_bp
            from routes.users import users_bp

            app.register_blueprint(auth_bp, url_prefix='/api/auth')
            app.register_blueprint(bookings_bp, url_prefix='/api/bookings')
            app.register_blueprint(workers_bp, url_prefix='/api/workers')
            app.register_blueprint(panic_bp, url_prefix='/api/panic')
            app.register_blueprint(users_bp, url_prefix='/api/users')
        except ImportError as e:
            print(f"Warning: Failed to import blueprints: {e}")

        @app.route('/')
        def index():
            try:
                return render_template('index.html')
            except Exception:
                return {"msg": "Clenzy Backend is Running"}

        @app.route('/health')
        def health():
            return {"status": "healthy", "service": "clenzy-backend"}, 200

        try:
            db.create_all()
        except Exception as e:
            print(f"Skipping DB create: {e}")

    return app
