from flask import Flask, jsonify
import requests

app = Flask(__name__)

CONSUL_URL = "https://consul:8501/v1/catalog/service/service_a"
CONSUL_CERT = ("/certs/service_b.pem", "/certs/service_b-key.pem")
CONSUL_VERIFY = "/certs/ca.pem"

@app.route('/fetch', methods=['GET'])
def fetch_from_service_a():
    try:
        # Query Consul for Service A's address
        response = requests.get(CONSUL_URL, cert=CONSUL_CERT, verify=CONSUL_VERIFY)
        if response.status_code == 200:
            service_instances = response.json()
            if not service_instances:
                return jsonify({"error": "No instances of service_a found in Consul"}), 404
            service_info = service_instances[0]  # Get the first instance
            service_a_address = service_info['ServiceAddress']
            service_a_port = service_info['ServicePort']

            # Call Service A
            service_a_url = f"https://{service_a_address}:{service_a_port}/data"
            service_a_response = requests.get(service_a_url, cert=CONSUL_CERT, verify=CONSUL_VERIFY)
            if service_a_response.status_code == 200:
                return jsonify({"service_b_message": "Data received", "service_a_data": service_a_response.json()}), 200
            else:
                return jsonify({"error": "Failed to fetch data from Service A"}), service_a_response.status_code
        else:
            return jsonify({"error": "Failed to query Consul"}), response.status_code
    except requests.exceptions.RequestException as e:
        return jsonify({"error": f"Connection to Consul failed: {str(e)}"}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "Service B is healthy"}), 200

if __name__ == '__main__':
  # Serve Service B over HTTPS using the generated certificates. Unlike
    # Service A, we do not require client authentication for browsers to
    # access the endpoint, so a simple cert/key pair is sufficient.
    ssl_context = ("/certs/service_b.pem", "/certs/service_b-key.pem")
    app.run(host='0.0.0.0', port=5001, ssl_context=ssl_context)
