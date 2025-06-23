from flask import Flask, jsonify
import ssl

app = Flask(__name__)

@app.route('/data', methods=['GET'])
def provide_data():
    return jsonify({"message": "Hello from Service A!"}), 200

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "Service A is healthy"}), 200

if __name__ == '__main__':
    context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    context.verify_mode = ssl.CERT_REQUIRED
    context.load_cert_chain('/certs/service_a.pem', '/certs/service_a-key.pem')
    context.load_verify_locations(cafile='/certs/ca.pem')
    app.run(host='0.0.0.0', port=5000, ssl_context=context)
