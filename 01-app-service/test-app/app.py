from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def home():
    return '''
    <html>
    <head><title>Azure Monitor POC</title></head>
    <body style="font-family: Arial; margin: 40px;">
        <h1>Azure Monitor POC - Flask App Running!</h1>
        <p>Status: <strong style="color: green;">Running</strong></p>
        <h2>Endpoints:</h2>
        <ul>
            <li><a href="/health">/health</a> - Health check</li>
            <li><a href="/api/test">/api/test</a> - Test API</li>
        </ul>
    </body>
    </html>
    '''

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'version': '1.0.0'}), 200

@app.route('/api/test')
def api_test():
    return jsonify({'message': 'Test endpoint working'}), 200

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8000))
    app.run(host='0.0.0.0', port=port, debug=False)
