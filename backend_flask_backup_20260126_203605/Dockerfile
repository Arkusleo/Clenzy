FROM python:3.9-slim

WORKDIR /app

# Copy the requirement file first to leverage Docker cache
COPY backend_flask/requirements.txt /app/backend_flask/requirements.txt
RUN pip install --no-cache-dir -r /app/backend_flask/requirements.txt

# Copy the entire backend_flask directory to /app/backend_flask
COPY backend_flask/ /app/backend_flask/

# Copy security_modules to /app/security_modules
COPY security_modules/ /app/security_modules/

# Set the working directory to the root /app so python can resolve modules
WORKDIR /app

# Add /app to PYTHONPATH so imports like 'from backend_flask.app import ...' work
ENV PYTHONPATH=/app

# Run the application using the module path
CMD ["python", "backend_flask/run.py"]
