from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from backend_flask.app import db, socketio
from backend_flask.models.models import Booking
from backend_flask.utils.responses import success_response, error_response
from security_modules.audit_logger import audit_logger

panic_bp = Blueprint('panic', __name__)

@panic_bp.route('/trigger', methods=['POST'])
@jwt_required()
def trigger_panic():
    user_identity = get_jwt_identity()
    data = request.json
    booking_id = data.get('booking_id')
    
    booking = Booking.query.get(booking_id)
    if booking:
        booking.is_panic_triggered = True
        db.session.commit()
        
        # Log the security incident
        audit_logger.log_action(user_identity, "PANIC_TRIGGER", f"Booking ID: {booking_id}", status="CRITICAL")
        
        # Notify Admin via SocketIO
        socketio.emit('panic_alert', {
            'booking_id': booking_id,
            'triggered_by': user_identity,
            'location': data.get('location')
        }, namespace='/admin')
        
        return success_response(None, "Panic alert triggered. Help is on the way.")
    
    return error_response("Booking not found", 404)
