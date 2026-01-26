from flask import Flask, request, jsonify
import random

app = Flask(__name__)

@app.route('/predict-risk', methods=['POST'])
def predict_risk():
    """
    CRADE ML Model Stub
    Input: user history, time, location
    Output: Risk Score [0, 1]
    """
    data = request.json
    # Simulate risk calculation logic
    # Higher risk if late night (22:00 - 05:00)
    risk_score = random.uniform(0.1, 0.4)
    
    # Simulate high risk scenario
    if data.get('is_late_night'):
        risk_score += 0.5
    
    return jsonify({
        "risk_score": round(risk_score, 2),
        "factors": ["time_of_day", "area_safety_index"]
    })

@app.route('/sentiment', methods=['POST'])
def analyze_sentiment():
    text = request.json.get('text', '')
    # Simple mock sentiment
    score = 0.8 if 'good' in text.lower() or 'great' in text.lower() else 0.3
    return jsonify({"sentiment_score": score})

if __name__ == '__main__':
    app.run(port=5001)
