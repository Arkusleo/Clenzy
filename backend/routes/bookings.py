from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from backend_flask.services.booking_service import BookingService
from backend_flask.utils.responses import success_response, error_response

bookings_bp = Blueprint('bookings', __name__)

@bookings_bp.route('/create', methods=['POST'])
@jwt_required()
def create_booking():
    user_phone = get_jwt_identity()
    data = request.json
    
    try:
        user_id = 1 # In real app, fetch ID from phone identity
        new_booking, team_type = BookingService.create_booking(user_id, data)
        
        return success_response({
            "booking_id": new_booking.id,
            "risk_assessment": {
                "score": float(new_booking.risk_score),
                "team_assigned": team_type
            }
        }, "Booking created successfully", 201)
    except Exception as e:
        return error_response(str(e), 500)

@bookings_bp.route('/<int:booking_id>', methods=['GET'])
@jwt_required()
def get_booking(booking_id):
    booking = Booking.query.get_or_404(booking_id)
    return jsonify({
        "id": booking.id,
        "status": booking.status,
        "risk_score": float(booking.risk_score)
    })
