from flask import Flask, jsonify
import requests

app = Flask(__name__)

SERVICE_A_URL = "http://service_a:5000/data"

@app.route('/fetch', methods=['GET'])
def fetch_from_service_a():
    try:
        response = requests.get(SERVICE_A_URL)
        if response.status_code == 200:
            data = response.json()
            return jsonify({"service_b_message": "Data received", "service_a_data": data}), 200
        else:
            return jsonify({"error": "Failed to fetch data from Service A"}), response.status_code
    except requests.exceptions.RequestException as e:
        return jsonify({"error": f"Connection to Service A failed: {str(e)}"}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "Service B is healthy"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
