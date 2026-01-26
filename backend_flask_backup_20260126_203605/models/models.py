from backend_flask.app import db
from datetime import datetime

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    phone_number = db.Column(db.String(15), unique=True, nullable=False)
    full_name = db.Column(db.String(100))
    email = db.Column(db.String(100), unique=True)
    is_verified = db.Column(db.Boolean, default=False)
    gender = db.Column(db.String(20))
    password_hash = db.Column(db.String(255)) # For admin login
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Worker(db.Model):
    __tablename__ = 'workers'
    id = db.Column(db.Integer, primary_key=True)
    phone_number = db.Column(db.String(15), unique=True, nullable=False)
    full_name = db.Column(db.String(100), nullable=False)
    rating = db.Column(db.Numeric(3, 2), default=5.00)
    verification_status = db.Column(db.String(20), default='Pending')
    current_lat = db.Column(db.Numeric(10, 8))
    current_lng = db.Column(db.Numeric(11, 8))

class Booking(db.Model):
    __tablename__ = 'bookings'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    service_id = db.Column(db.Integer) # Simplified for now
    worker_id = db.Column(db.Integer, db.ForeignKey('workers.id'), nullable=True)
    status = db.Column(db.Enum('Pending', 'Assigned', 'InProgress', 'Completed', 'Cancelled'), default='Pending')
    booking_time = db.Column(db.DateTime, nullable=False)
    address_text = db.Column(db.Text, nullable=False)
    risk_score = db.Column(db.Numeric(3, 2), default=0.0)
    is_panic_triggered = db.Column(db.Boolean, default=False)
