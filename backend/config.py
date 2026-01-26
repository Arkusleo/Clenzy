import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'clenzy-super-secret-key')
    
    # Database Configuration
    DB_HOST = os.getenv('DB_HOST')
    DB_USER = os.getenv('DB_USER')
    DB_PASSWORD = os.getenv('DB_PASSWORD')
    DB_NAME = os.getenv('DB_NAME')
    DB_PORT = os.getenv('DB_PORT')
    
    if DB_HOST and DB_USER and DB_PASSWORD and DB_NAME:
        # Construct MySQL connection string
        # Limit port usage if provided
        port_str = f":{DB_PORT}" if DB_PORT else ""
        SQLALCHEMY_DATABASE_URI = f"mysql+mysqlconnector://{DB_USER}:{DB_PASSWORD}@{DB_HOST}{port_str}/{DB_NAME}"
    else:
        # Fallback to provided URL or SQLite
        SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL', 'sqlite:///project.db')
