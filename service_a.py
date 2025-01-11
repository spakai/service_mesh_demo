from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/data', methods=['GET'])
def provide_data():
    return jsonify({"message": "Hello from Service A!"}), 200

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "Service A is healthy"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
