import sys
import os

# Ensure the project root is in the path
sys.path.append(os.getcwd())

from backend_flask.app import create_app, socketio

# Create the application instance
app = create_app()

# Automatically create tables for the user 
with app.app_context():
    try:
        from backend_flask.app import db
        db.create_all()
        print("✅ Database tables checked/created.")
    except Exception as e:
        print(f"⚠️ Note: Database table creation skipped: {e}")

if __name__ == "__main__":
    print("--------------------------------------------------")
    print("🚀 Clenzy Backend ACTIVE on http://localhost:5000")
    print("--------------------------------------------------")
    # Disabling reloader for stability on Windows with SocketIO
    socketio.run(app, debug=True, use_reloader=False, host='0.0.0.0', port=5000)
