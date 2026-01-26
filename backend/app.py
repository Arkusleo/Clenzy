import os
import sys

# Ensure current directory is in path for imports
sys.path.append(os.getcwd())

from core import create_app, socketio

app = create_app()

if __name__ == "__main__":
    print("--------------------------------------------------")
    print("🚀 Clenzy Backend Starting...")
    print("--------------------------------------------------")
    port = int(os.environ.get("PORT", 5000))
    # Listen on 0.0.0.0 for Railway
    socketio.run(app, host='0.0.0.0', port=port)
