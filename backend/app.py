import os
import sys

# Ensure current directory is in path for imports
sys.path.append(os.getcwd())

from core import create_app, socketio

app = create_app()

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    print("PORT from Railway:", port)
    app.run(host="0.0.0.0", port=port)

