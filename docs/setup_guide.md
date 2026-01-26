# How to Access and Run Clenzy

To access the Clenzy platform, you need to run the backend and the appropriate frontend application.

## 1. Quick Start: Running Everything with Docker (Recommended)
This is the easiest way to start the backend, database, and ML services.

1. Ensure you have **Docker Desktop** installed and running.
2. Open a terminal in `e:\project clenzy\infra_deployment`.
3. Run the following command:
   ```bash
   docker-compose up --build
   ```
4. The backend will be available at `http://localhost:5000`.

---

## 2. Accessing the Admin Web Panel
The admin panel is built with Flutter Web.

1. Open a terminal in `e:\project clenzy\admin_panel_flutter_web`.
2. Run the following command:
   ```bash
   flutter run -d chrome
   ```
3. The website will open in your browser (usually at `http://localhost:random_port`).

---

## 3. Running the Mobile Apps (Customer & Employee)
Since these are Flutter apps, you can run them on an emulator or a real device.

### For Customer App:
1. Open a terminal in `e:\project clenzy\frontend_customer_flutter`.
2. Run:
   ```bash
   flutter run
   ```

### For Employee App:
1. Open a terminal in `e:\project clenzy\frontend_employee_flutter`.
2. Run:
   ```bash
   flutter run
   ```

---

## 4. Manual Backend Setup (No Docker)
If you prefer to run the backend manually without Docker:

1. **Database**: Create a MySQL database named `clenzy_db` and run the script in `database_schema/schema.sql`.
2. **Backend**:
   - Navigate to `backend_flask`.
   - Install dependencies: `pip install -r requirements.txt`.
   - Start the server: `python app.py` (Wait! You'll need to call the factory in a runner file).

### Runner for Manual Start:
Create a file `run.py` in `e:\project clenzy\backend_flask`:
```python
from app import create_app, socketio

app = create_app()

if __name__ == "__main__":
    socketio.run(app, debug=True, port=5000)
```
Then run: `python run.py`.
