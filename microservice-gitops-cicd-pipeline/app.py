from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    """Main landing page endpoint"""
    return """
    <html>
        <head>
            <title>Vijay's DevOps Portfolio</title>
            <style>
                body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; background-color: #f4f6f9; }
                h1 { color: #232f3e; }
                .container { background: white; padding: 30px; border-radius: 10px; display: inline-block; box-shadow: 0px 4px 6px rgba(0,0,0,0.1); }
                .badge { background-color: #4CAF50; color: white; padding: 5px 10px; border-radius: 5px; font-weight: bold; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🚀 Success! Project 1 is Live!</h1>
                <p>Your Multi-Stage GitOps CI/CD Pipeline is working perfectly.</p>
                <p>Deployed application status: <span class="badge">HEALTHY</span></p>
            </div>
        </body>
    </html>
    """

@app.route('/health')
def health():
    """Health check endpoint for Kubernetes and ALB liveness probes"""
    return jsonify({
        "status": "healthy",
        "version": "1.0.0",
        "engine": "Kubernetes (Minikube)"
    }), 200

if __name__ == '__main__':
    # Must bind to 0.0.0.0 so it listens to traffic outside its container
    app.run(host='0.0.0.0', port=5000)