"""
iLab+ Eye Disease Detection API Server
Provides real-time eye disease prediction using the trained model
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
from PIL import Image
import io
import base64
import os

# Import TensorFlow and Keras
try:
    import tensorflow as tf
    from tensorflow.keras.models import load_model
    print("✅ Using TensorFlow Keras")
    TENSORFLOW_AVAILABLE = True
except ImportError as e:
    print(f"⚠️  TensorFlow not available: {e}")
    print("   Vision test endpoint will still work")
    TENSORFLOW_AVAILABLE = False
    tf = None
    load_model = None

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter web

# Configuration - try best_eye_model.keras first
import pathlib
BASE_DIR = pathlib.Path(__file__).parent.parent.parent
MODEL_PATH = BASE_DIR / "ml_models" / "Eye-Disease-Prediction" / "best_eye_model.keras"

# Class names matching the trained model
CLASS_NAMES = [
    'Conjectivites',
    'Eyelid',
    'Normal Eye',
    'cataract',
    'Pterygium'
]

# Map to display names
DISPLAY_NAMES = {
    'Conjectivites': 'Conjunctivitis',
    'Eyelid': 'Eyelid',
    'Normal Eye': 'Normal Eye',
    'cataract': 'cataract',
    'Pterygium': 'Pterygium'
}

# Global model variable
model = None

def load_keras_model():
    """Load the Keras model - handles corrupted model files"""
    global model
    
    if not TENSORFLOW_AVAILABLE:
        print("⚠️  TensorFlow not available - skipping model loading")
        return False

    # Try multiple model files
    model_paths = [
        BASE_DIR / "ml_models" / "Eye-Disease-Prediction" / "best_eye_model.keras",
        BASE_DIR / "ml_models" / "Eye-Disease-Prediction" / "eye_disease_classifier.keras"
    ]

    for path in model_paths:
        if not os.path.exists(path):
            continue

        try:
            print(f"📦 Trying to load model from: {path}")

            # Method 1: Try normal loading
            try:
                model = load_model(path, compile=False)
                model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
                print("✅ Model loaded successfully (compile=False)!")
                print(f"   Input shape: {model.input_shape}")
                print(f"   Output shape: {model.output_shape}")
                return True
            except Exception as e1:
                print(f"   Method 1 failed: {str(e1)[:100]}")

            # Method 2: Try with safe_mode
            try:
                model = load_model(path, compile=False, safe_mode=False)
                model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
                print("✅ Model loaded successfully (safe_mode=False)!")
                print(f"   Input shape: {model.input_shape}")
                print(f"   Output shape: {model.output_shape}")
                return True
            except Exception as e2:
                print(f"   Method 2 failed: {str(e2)[:100]}")

        except Exception as e:
            print(f"   ❌ All methods failed for {path}")
            continue

    print(f"❌ Could not load any model file")
    print(f"   The model files appear to be corrupted or incompatible")
    print(f"   Using DEMO MODE for now - returning mock predictions")
    return False

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model_loaded': model is not None,
        'classes': CLASS_NAMES,
        'version': '1.0.0'
    })

@app.route('/predict', methods=['POST'])
def predict():
    """
    Prediction endpoint
    Accepts: multipart/form-data with 'image' file
    Returns: JSON with predictions
    """
    # DEMO MODE: If model not loaded, return demo predictions
    if model is None:
        print("⚠️  DEMO MODE: Returning mock predictions")
        probabilities = {
            'Normal Eye': 0.75,
            'Conjunctivitis': 0.12,
            'cataract': 0.08,
            'Pterygium': 0.04,
            'Eyelid': 0.01
        }
        return jsonify({
            'success': True,
            'predicted_class': 'Normal Eye',
            'confidence': 0.75,
            'probabilities': probabilities,
            'all_probabilities': probabilities,
            'demo_mode': True,
            'message': 'Model not loaded - showing demo prediction',
            'model_info': {
                'input_size': '224x224',
                'classes': len(CLASS_NAMES)
            }
        })

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
        original_size = img.size
        print(f"Original size: {original_size}")

        # Resize to 224x224 (model input size)
        img = img.resize((224, 224))
        img_array = np.array(img).astype(np.float32)

        # Normalize: rescale to [0, 1] (matching training preprocessing)
        img_array = img_array / 255.0
        img_array = np.expand_dims(img_array, axis=0)

        print(f"Preprocessed shape: {img_array.shape}")
        print(f"Value range: [{img_array.min():.3f}, {img_array.max():.3f}]")

        # Run prediction
        print("🔮 Running inference...")
        predictions = model.predict(img_array, verbose=0)[0]

        # Get results
        predicted_idx = int(np.argmax(predictions))
        predicted_class = CLASS_NAMES[predicted_idx]
        display_name = DISPLAY_NAMES.get(predicted_class, predicted_class)
        confidence = float(predictions[predicted_idx])

        # Create probability dictionary with display names
        probabilities = {}
        for i, (name, prob) in enumerate(zip(CLASS_NAMES, predictions)):
            display = DISPLAY_NAMES.get(name, name)
            probabilities[display] = float(prob)

        # Sort by probability
        sorted_probs = dict(sorted(
            probabilities.items(),
            key=lambda x: x[1],
            reverse=True
        ))

        print(f"✅ Prediction: {display_name} ({confidence:.2%})")
        print(f"   Top 3 predictions:")
        for i, (name, prob) in enumerate(list(sorted_probs.items())[:3]):
            print(f"   {i+1}. {name}: {prob:.2%}")

        return jsonify({
            'success': True,
            'predicted_class': display_name,
            'confidence': confidence,
            'probabilities': sorted_probs,
            'all_probabilities': probabilities,
            'model_info': {
                'input_size': '224x224',
                'classes': len(CLASS_NAMES)
            }
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
        'classes': [DISPLAY_NAMES.get(name, name) for name in CLASS_NAMES],
        'count': len(CLASS_NAMES)
    })

@app.route('/vision-test', methods=['POST'])
def vision_test():
    """
    Process vision test results and return analysis
    Expects JSON: {
        "test_mode": "single_letter" or "full_chart",
        "total_questions": 5,
        "correct_answers": 4,
        "responses": [
            {
                "letter_shown": "E",
                "user_response": "E",
                "is_correct": true,
                "timestamp": "2024-01-01T12:00:00"
            }
        ],
        "timestamp": "2024-01-01T12:00:00"
    }
    Returns: {
        "health_score": 85,
        "vision_status": "Good",
        "acuity_level": "20/20",
        "analysis": {...},
        "recommendations": [...]
    }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        # Extract test data
        total_questions = data.get('total_questions', 0)
        correct_answers = data.get('correct_answers', 0)
        responses = data.get('responses', [])
        test_mode = data.get('test_mode', 'single_letter')
        
        # Calculate accuracy
        if total_questions == 0:
            accuracy = 0
        else:
            accuracy = (correct_answers / total_questions) * 100
        
        # Calculate health score (0-100)
        # Base score on accuracy with some adjustments
        health_score = int(accuracy)
        
        # Determine vision status
        if accuracy >= 90:
            vision_status = "Excellent"
            acuity_level = "20/20 or better"
            status_color = "green"
        elif accuracy >= 75:
            vision_status = "Good"
            acuity_level = "20/25 to 20/30"
            status_color = "light_green"
        elif accuracy >= 60:
            vision_status = "Fair"
            acuity_level = "20/40 to 20/50"
            status_color = "yellow"
        elif accuracy >= 40:
            vision_status = "Below Average"
            acuity_level = "20/70 to 20/100"
            status_color = "orange"
        else:
            vision_status = "Poor"
            acuity_level = "20/200 or worse"
            status_color = "red"
        
        # Generate recommendations
        recommendations = []
        if accuracy < 80:
            recommendations.append("Schedule a comprehensive eye examination")
            recommendations.append("Ensure proper lighting when reading")
            
        if accuracy < 60:
            recommendations.append("Consult an optometrist or ophthalmologist soon")
            recommendations.append("Avoid prolonged screen time without breaks")
            
        if accuracy >= 80:
            recommendations.append("Continue regular eye check-ups annually")
            recommendations.append("Maintain good eye health habits")
        
        recommendations.append("Follow the 20-20-20 rule for screen use")
        recommendations.append("Protect eyes from UV radiation with sunglasses")
        
        # Analyze response patterns
        analysis = {
            "total_tests": total_questions,
            "correct_responses": correct_answers,
            "accuracy_percentage": round(accuracy, 1),
            "test_mode": test_mode,
            "timestamp": data.get('timestamp', ''),
        }
        
        # Detailed analysis
        if responses:
            incorrect_letters = [r['letter_shown'] for r in responses if not r.get('is_correct', False)]
            analysis['missed_letters'] = incorrect_letters
            analysis['response_count'] = len(responses)
        
        result = {
            'success': True,
            'health_score': health_score,
            'vision_status': vision_status,
            'acuity_level': acuity_level,
            'status_color': status_color,
            'analysis': analysis,
            'recommendations': recommendations,
            'test_summary': {
                'completed_at': data.get('timestamp', ''),
                'test_duration': f"{total_questions * 5} seconds (estimated)"
            }
        }
        
        print(f"✅ Vision test processed: {correct_answers}/{total_questions} ({accuracy:.1f}%)")
        print(f"   Health Score: {health_score}, Status: {vision_status}")
        
        return jsonify(result)
        
    except Exception as e:
        print(f"❌ Vision test error: {e}")
        import traceback
        traceback.print_exc()
        
        return jsonify({
            'error': 'Vision test processing failed',
            'message': str(e)
        }), 500

if __name__ == '__main__':
    print("=" * 70)
    print("🚀 iLab+ Eye Disease Detection API Server")
    print("=" * 70)
    print(f"Model path: {MODEL_PATH}")
    print("")

    # Load model on startup
    model_loaded = load_keras_model()

    if model_loaded:
        print("\n" + "=" * 70)
        print("📡 Server Starting...")
        print("=" * 70)
        print("   🌐 Local:   http://localhost:5000")
        print("   🌐 Network: http://<your-ip>:5000")
        print("")
        print("📋 Endpoints:")
        print("   GET  /health   - Check server status")
        print("   POST /predict  - Get disease prediction")
        print("   GET  /classes  - List all disease classes")
        print("")
        print("🎯 Detectable Diseases:")
        for i, name in enumerate(CLASS_NAMES, 1):
            print(f"   {i}. {DISPLAY_NAMES.get(name, name)}")
        print("\n" + "=" * 70)
        print("✅ Server Ready! Waiting for requests...")
        print("=" * 70)
    else:
        print("\n" + "=" * 70)
        print("⚠️  Server will start but predictions won't work")
        print("   Please check the model file path and restart")
        print("=" * 70)

    # Start Flask server
    app.run(
        host='0.0.0.0',  # Accessible from network
        port=5000,
        debug=False,     # Set to False for production
        threaded=True
    )
