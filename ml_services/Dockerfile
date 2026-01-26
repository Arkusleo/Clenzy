FROM python:3.9-slim

WORKDIR /app

RUN pip install flask

COPY ml_services/app.py .

CMD ["python", "app.py"]
