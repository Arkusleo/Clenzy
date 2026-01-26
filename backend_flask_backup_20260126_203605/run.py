from app import create_app, socketio

app = create_app()

import os

if __name__ == "__main__":
    port = int(os.getenv("PORT", 5000))
    debug = os.getenv("FLASK_DEBUG", "True").lower() == "true"
    socketio.run(app, debug=debug, host='0.0.0.0', port=port)
