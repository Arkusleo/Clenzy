from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from backend_flask.app import db
from backend_flask.models.models import Worker

workers_bp = Blueprint('workers', __name__)

@workers_bp.route('/nearby', methods=['GET'])
def get_nearby_workers():
    lat = request.args.get('lat')
    lng = request.args.get('lng')
    # In production, use spatial queries (GIS)
    workers = Worker.query.filter(Worker.is_active == True).limit(10).all()
    return jsonify([{
        "id": w.id,
        "name": w.full_name,
        "lat": float(w.current_lat) if w.current_lat else None,
        "lng": float(w.current_lng) if w.current_lng else None
    } for w in workers])

@workers_bp.route('/update-location', methods=['POST'])
@jwt_required()
def update_location():
    data = request.json
    worker_id = data.get('worker_id')
    worker = Worker.query.get(worker_id)
    if worker:
        worker.current_lat = data.get('lat')
        worker.current_lng = data.get('lng')
        db.session.commit()
        return jsonify({"msg": "Location updated"}), 200
    return jsonify({"msg": "Worker not found"}), 404
