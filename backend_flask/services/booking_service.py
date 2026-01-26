from backend_flask.models.models import Booking, db
import requests
import os

class BookingService:
    @staticmethod
    def calculate_risk_and_assign_team(data):
        """
        CRADE Service Logic
        Interfaces with ML microservice to determine risk.
        """
        ml_url = os.getenv('ML_SERVICE_URL', 'http://localhost:5001')
        try:
            risk_response = requests.post(f'{ml_url}/predict-risk', json=data, timeout=2).json()
            risk_score = risk_response.get('risk_score', 0.5)
        except:
            risk_score = 0.5 # Default fallback
            
        team_type = 'Solo'
        if risk_score > 0.7:
            team_type = 'Dual'
        elif risk_score > 0.9:
            team_type = 'Escalated'
            
        return risk_score, team_type

    @staticmethod
    def create_booking(user_id, booking_data):
        risk_score, team_type = BookingService.calculate_risk_and_assign_team(booking_data)
        
        new_booking = Booking(
            user_id=user_id,
            service_id=booking_data.get('service_id'),
            status='Pending',
            booking_time=booking_data.get('booking_time'),
            address_text=booking_data.get('address'),
            risk_score=risk_score
        )
        
        db.session.add(new_booking)
        db.session.commit()
        return new_booking, team_type
