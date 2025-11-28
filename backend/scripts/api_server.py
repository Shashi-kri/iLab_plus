"""
Flask API Server for Eye Disease Prediction
Usage: python api_server.py

This creates a REST API endpoint that Flutter can call to get predictions
Alternative to using TensorFlow Lite directly in the app.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
import numpy as np
from PIL import Image
import io
import base64
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter web and mobile

# Configuration
MODEL_PATH = "best_eye_model.keras"  # Update this path
CLASS_NAMES = [
    'Conjunctivitis',
    'Eyelid',
    'Normal Eye',
    'cataract',
    'Pterygium'
]

# Global model variable
model = None

def load_model():
    """Load the TensorFlow model"""
    global model
    try:
        if os.path.exists(MODEL_PATH):
            print(f"📦 Loading model from: {MODEL_PATH}")
            model = tf.keras.models.load_model(MODEL_PATH)
            print("✅ Model loaded successfully")
            return True
        else:
            print(f"❌ Model file not found at: {MODEL_PATH}")
            print("Please update MODEL_PATH to point to your model file")
            return False
    except Exception as e:
        print(f"❌ Error loading model: {e}")
        return False

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model_loaded': model is not None,
        'classes': len(CLASS_NAMES)
    })

@app.route('/predict', methods=['POST'])
def predict():
    """
    Prediction endpoint
    Accepts: multipart/form-data with 'image' file
             or JSON with 'image_base64' field
    Returns: JSON with predictions
    """
    if model is None:
        return jsonify({
            'error': 'Model not loaded',
            'message': 'Server is running but model file is not available'
        }), 503

    try:
        # Get image from request
        img = None

        if 'image' in request.files:
            # Multipart file upload
            file = request.files['image']
            img = Image.open(file.stream).convert('RGB')
            print(f"✓ Received image file: {file.filename}")

        elif request.is_json and 'image_base64' in request.json:
            # Base64 encoded image
            img_data = base64.b64decode(request.json['image_base64'])
            img = Image.open(io.BytesIO(img_data)).convert('RGB')
            print("✓ Received base64 image")

        else:
            return jsonify({
                'error': 'No image provided',
                'message': 'Send image as multipart/form-data or base64 JSON'
            }), 400

        # Preprocess image
        print(f"Original size: {img.size}")
        img = img.resize((224, 224))
        img_array = np.array(img).astype(np.float32)

        # EfficientNet preprocessing: normalize to [-1, 1]
        img_array = (img_array / 127.5) - 1.0
        img_array = np.expand_dims(img_array, axis=0)

        print(f"Preprocessed shape: {img_array.shape}")

        # Run prediction
        print("🔮 Running inference...")
        predictions = model.predict(img_array, verbose=0)[0]

        # Get results
        predicted_idx = int(np.argmax(predictions))
        predicted_class = CLASS_NAMES[predicted_idx]
        confidence = float(predictions[predicted_idx])

        # Create probability dictionary
        probabilities = {
            name: float(prob)
            for name, prob in zip(CLASS_NAMES, predictions)
        }

        # Sort by probability
        sorted_probs = dict(sorted(
            probabilities.items(),
            key=lambda x: x[1],
            reverse=True
        ))

        print(f"✅ Prediction: {predicted_class} ({confidence:.2%})")

        return jsonify({
            'success': True,
            'predicted_class': predicted_class,
            'confidence': confidence,
            'probabilities': sorted_probs,
            'all_probabilities': probabilities
        })

    except Exception as e:
        print(f"❌ Prediction error: {e}")
        import traceback
        traceback.print_exc()

        return jsonify({
            'error': 'Prediction failed',
            'message': str(e)
        }), 500

@app.route('/classes', methods=['GET'])
def get_classes():
    """Return list of disease classes"""
    return jsonify({
        'classes': CLASS_NAMES,
        'count': len(CLASS_NAMES)
    })

if __name__ == '__main__':
    print("=" * 60)
    print("🚀 Eye Disease Prediction API Server")
    print("=" * 60)

    # Load model on startup
    model_loaded = load_model()

    if model_loaded:
        print("\n📡 Starting server...")
        print("   Local:   http://localhost:5000")
        print("   Network: http://<your-ip>:5000")
        print("\nEndpoints:")
        print("   GET  /health  - Check server status")
        print("   POST /predict - Get disease prediction")
        print("   GET  /classes - List all disease classes")
        print("\n" + "=" * 60)
    else:
        print("\n⚠️  Server will start but predictions won't work")
        print("    Please add your model file and restart")
        print("\n" + "=" * 60)

    # Start Flask server
    app.run(
        host='0.0.0.0',  # Accessible from network
        port=5000,
        debug=True,
        threaded=True
    )
