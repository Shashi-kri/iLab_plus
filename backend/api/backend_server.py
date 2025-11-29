"""
iLab+ Eye Disease Detection API Server
Provides real-time eye disease prediction using multiple trained models
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
from PIL import Image
import io
import base64
import os
import pathlib

# Import TensorFlow and Keras
try:
    import tensorflow as tf
    from tensorflow.keras.models import load_model
    from tensorflow.keras.applications.efficientnet import preprocess_input
    print("✅ Using TensorFlow Keras")
except ImportError as e:
    print(f"❌ TensorFlow not available: {e}")
    raise

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter web

# Configuration
BASE_DIR = pathlib.Path(__file__).parent.parent.parent
MODELS_DIR = BASE_DIR / "machine_learning" / "trained_models"

# Model configuration - each model is a binary classifier
MODEL_CONFIGS = {
    'cataract': {
        'path': MODELS_DIR / "Cataract_Classifier.keras",
        'classes': ['Normal Eye', 'Cataract'],
        'display_name': 'Cataract'
    },
    'conjectivites': {
        'path': MODELS_DIR / "Conjectivites_Classifier.keras",
        'classes': ['Conjectivites', 'Normal Eye'],
        'display_name': 'Conjunctivitis'
    },
    'eyelid': {
        'path': MODELS_DIR / "Eyelid_Classifier.keras",
        'classes': ['Eyelid', 'Normal Eye'],
        'display_name': 'Eyelid'
    },
    'pterygium': {
        'path': MODELS_DIR / "Pterygium_Classifier.keras",
        'classes': ['Normal Eye', 'Pterygium'],
        'display_name': 'Pterygium'
    }
}

# All possible classes
ALL_CLASSES = ['Normal Eye', 'Cataract', 'Conjunctivitis', 'Eyelid', 'Pterygium']

# Display name mapping
DISPLAY_NAMES = {
    'Normal Eye': 'Normal Eye',
    'Cataract': 'Cataract',
    'Conjectivites': 'Conjunctivitis',
    'Conjunctivitis': 'Conjunctivitis',
    'Eyelid': 'Eyelid',
    'Pterygium': 'Pterygium'
}

# Global models dictionary
models = {}

def load_all_models():
    """Load all disease detection models"""
    global models
    models = {}
    loaded_count = 0
    
    print("\n" + "=" * 70)
    print("📦 Loading Disease Detection Models")
    print("=" * 70)
    
    for model_name, config in MODEL_CONFIGS.items():
        model_path = config['path']
        
        if not os.path.exists(model_path):
            print(f"⚠️  Model not found: {model_path}")
            continue
        
        try:
            print(f"\n📦 Loading {model_name} model from: {model_path}")
            
            # Try loading the model
            try:
                model = load_model(model_path, compile=False)
                # Compile with appropriate loss function for binary classification
                model.compile(
                    optimizer='adam',
                    loss='binary_crossentropy',
                    metrics=['accuracy']
                )
                models[model_name] = {
                    'model': model,
                    'classes': config['classes'],
                    'display_name': config['display_name']
                }
                loaded_count += 1
                print(f"✅ {config['display_name']} model loaded successfully!")
                print(f"   Input shape: {model.input_shape}")
                print(f"   Output shape: {model.output_shape}")
                print(f"   Classes: {config['classes']}")
            except Exception as e:
                print(f"❌ Failed to load {model_name} model: {str(e)[:200]}")
                continue
                
        except Exception as e:
            print(f"❌ Error loading {model_name}: {str(e)[:200]}")
            continue
    
    print("\n" + "=" * 70)
    print(f"✅ Loaded {loaded_count}/{len(MODEL_CONFIGS)} models")
    print("=" * 70)
    
    return loaded_count > 0

def preprocess_image(img):
    """
    Preprocess image for EfficientNet models
    Resize to 224x224 and apply EfficientNet preprocessing
    """
    # Resize to 224x224
    img = img.resize((224, 224))
    img_array = np.array(img).astype(np.float32)
    
    # Expand dimensions for batch
    img_array = np.expand_dims(img_array, axis=0)
    
    # Apply EfficientNet preprocessing (normalizes to [-1, 1] range)
    img_array = preprocess_input(img_array)
    
    return img_array

def predict_with_single_model(img_array, disease_name):
    """
    Run prediction on a single disease model
    Returns: Dictionary with prediction result (Normal Eye or Disease)
    """
    # Map disease name to model key
    disease_lower = disease_name.lower()
    model_key_map = {
        'cataract': 'cataract',
        'conjunctivitis': 'conjectivites',
        'conjectivites': 'conjectivites',
        'eyelid': 'eyelid',
        'pterygium': 'pterygium'
    }
    
    model_key = model_key_map.get(disease_lower)
    if not model_key or model_key not in models:
        return None
    
    model_info = models[model_key]
    model = model_info['model']
    classes = model_info['classes']
    display_name = model_info['display_name']
    
    try:
        # Get prediction
        prediction = model.predict(img_array, verbose=0)[0]
        
        # Handle binary classification output
        if len(prediction.shape) == 0:
            prob_disease = float(prediction)
            prob_normal = 1.0 - prob_disease
        else:
            if len(prediction) >= 2:
                normal_idx = classes.index('Normal Eye')
                disease_idx = 1 - normal_idx
                prob_normal = float(prediction[normal_idx])
                prob_disease = float(prediction[disease_idx])
            else:
                prob_disease = float(prediction[0])
                prob_normal = 1.0 - prob_disease
        
        # Determine result
        if prob_disease > 0.5:
            predicted_class = display_name
            confidence = prob_disease
            status = 'Positive'
        else:
            predicted_class = 'Normal Eye'
            confidence = prob_normal
            status = 'Normal'
        
        print(f"   Primary Check ({display_name}): {status} (Confidence: {confidence:.3f})")
        
        return {
            'predicted_class': predicted_class,
            'status': status,
            'confidence': confidence,
            'disease_prob': prob_disease,
            'normal_prob': prob_normal,
            'disease_name': display_name
        }
    except Exception as e:
        print(f"❌ Error predicting with {model_key}: {str(e)[:200]}")
        return None

def predict_with_remaining_models(img_array, exclude_disease):
    """
    Run prediction on all models except the excluded disease
    Returns: Dictionary with predictions for remaining diseases
    """
    # Map disease name to model key
    disease_lower = exclude_disease.lower()
    model_key_map = {
        'cataract': 'cataract',
        'conjunctivitis': 'conjectivites',
        'conjectivites': 'conjectivites',
        'eyelid': 'eyelid',
        'pterygium': 'pterygium'
    }
    
    exclude_model_key = model_key_map.get(disease_lower)
    remaining_probabilities = {}
    
    # Run inference on remaining models
    for model_name, model_info in models.items():
        # Skip the excluded disease model
        if exclude_model_key and model_name == exclude_model_key:
            continue
        
        try:
            model = model_info['model']
            classes = model_info['classes']
            display_name = model_info['display_name']
            
            # Get prediction
            prediction = model.predict(img_array, verbose=0)[0]
            
            # Handle binary classification output
            if len(prediction.shape) == 0:
                prob_disease = float(prediction)
                prob_normal = 1.0 - prob_disease
            else:
                if len(prediction) >= 2:
                    normal_idx = classes.index('Normal Eye')
                    disease_idx = 1 - normal_idx
                    prob_normal = float(prediction[normal_idx])
                    prob_disease = float(prediction[disease_idx])
                else:
                    prob_disease = float(prediction[0])
                    prob_normal = 1.0 - prob_disease
            
            # Store disease probability (exclude Normal Eye from remaining predictions)
            if display_name == 'Conjunctivitis':
                remaining_probabilities['Conjunctivitis'] = prob_disease
            else:
                remaining_probabilities[display_name] = prob_disease
            
            print(f"   {display_name}: {prob_disease:.3f}")
            
        except Exception as e:
            print(f"❌ Error predicting with {model_name}: {str(e)[:200]}")
            continue
    
    # Sort by probability
    sorted_probs = dict(sorted(
        remaining_probabilities.items(),
        key=lambda x: x[1],
        reverse=True
    ))
    
    return sorted_probs

def predict_with_all_models(img_array):
    """
    Run prediction on all loaded models and combine results
    Returns: Dictionary with combined predictions
    """
    results = {}
    disease_predictions = {}
    
    # Initialize probabilities for all classes
    probabilities = {cls: 0.0 for cls in ALL_CLASSES}
    
    # Run inference on each model
    for model_name, model_info in models.items():
        try:
            model = model_info['model']
            classes = model_info['classes']  # Class order for this model
            display_name = model_info['display_name']
            
            # Get prediction
            prediction = model.predict(img_array, verbose=0)[0]
            
            # Handle binary classification output
            # Each model outputs 2 probabilities via softmax
            if len(prediction.shape) == 0:
                # Single value output (sigmoid) - unlikely but handle it
                prob_disease = float(prediction)
                prob_normal = 1.0 - prob_disease
            else:
                # Two-value output (softmax) - standard case
                if len(prediction) >= 2:
                    # Get index of 'Normal Eye' in the classes list
                    normal_idx = classes.index('Normal Eye')
                    disease_idx = 1 - normal_idx
                    
                    prob_normal = float(prediction[normal_idx])
                    prob_disease = float(prediction[disease_idx])
                else:
                    # Fallback - single output
                    prob_disease = float(prediction[0])
                    prob_normal = 1.0 - prob_disease
            
            # Store results
            results[model_name] = {
                'disease_prob': prob_disease,
                'normal_prob': prob_normal,
                'predicted': display_name if prob_disease > 0.5 else 'Normal Eye'
            }
            
            # Update probabilities - use maximum across all models
            probabilities['Normal Eye'] = max(probabilities['Normal Eye'], prob_normal)
            
            # Map disease probability to correct class name
            if display_name == 'Conjunctivitis':
                probabilities['Conjunctivitis'] = max(probabilities.get('Conjunctivitis', 0.0), prob_disease)
            else:
                probabilities[display_name] = max(probabilities.get(display_name, 0.0), prob_disease)
            
            # Track disease predictions (only if confidence > 0.5)
            if prob_disease > 0.5:
                disease_predictions[display_name] = prob_disease
            
            print(f"   {display_name}: Disease={prob_disease:.3f}, Normal={prob_normal:.3f}")
            
        except Exception as e:
            print(f"❌ Error predicting with {model_name}: {str(e)[:200]}")
            import traceback
            traceback.print_exc()
            continue
    
    # Determine final prediction
    if disease_predictions:
        # If any disease is detected, use the one with highest probability
        predicted_disease = max(disease_predictions.items(), key=lambda x: x[1])
        predicted_class = predicted_disease[0]
        confidence = predicted_disease[1]
    else:
        # All models predict normal
        predicted_class = 'Normal Eye'
        confidence = probabilities['Normal Eye']
    
    # Normalize probabilities to sum to 1 (softmax-like normalization)
    total = sum(probabilities.values())
    if total > 0:
        probabilities = {k: v / total for k, v in probabilities.items()}
    
    return {
        'predicted_class': predicted_class,
        'confidence': confidence,
        'probabilities': probabilities,
        'model_results': results
    }

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'models_loaded': len(models),
        'total_models': len(MODEL_CONFIGS),
        'classes': ALL_CLASSES,
        'version': '2.0.0'
    })

@app.route('/predict', methods=['POST'])
def predict():
    """
    Prediction endpoint
    Accepts: 
        - multipart/form-data with 'image' file
        - JSON with 'image_base64' and optional 'disease' parameter
        - Query parameter 'disease' to specify which disease to check
    
    If 'disease' is specified:
        - Checks only that disease model first
        - Returns Normal/Positive status for that disease
        - Shows remaining disease predictions below (excluding the checked disease)
    
    If 'disease' is not specified:
        - Runs all models and returns combined results
    """
    # DEMO MODE: If no models loaded, return demo predictions
    if not models:
        print("⚠️  DEMO MODE: No models loaded, returning mock predictions")
        probabilities = {
            'Normal Eye': 0.75,
            'Conjunctivitis': 0.12,
            'Cataract': 0.08,
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
            'message': 'Models not loaded - showing demo prediction',
            'model_info': {
                'input_size': '224x224',
                'classes': len(ALL_CLASSES)
            }
        })

    try:
        # Get disease parameter from query string, form data, or JSON
        disease_to_check = None
        if request.args.get('disease'):
            disease_to_check = request.args.get('disease')
        elif request.form.get('disease'):
            disease_to_check = request.form.get('disease')
        elif request.is_json and 'disease' in request.json:
            disease_to_check = request.json.get('disease')
        
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

        # Preprocess for EfficientNet
        img_array = preprocess_image(img)
        
        print(f"Preprocessed shape: {img_array.shape}")
        print(f"Value range: [{img_array.min():.3f}, {img_array.max():.3f}]")

        # If disease is specified, check only that disease first
        if disease_to_check:
            print(f"🔍 Checking specific disease: {disease_to_check}")
            
            # Run primary disease check
            primary_result = predict_with_single_model(img_array, disease_to_check)
            
            if not primary_result:
                return jsonify({
                    'error': 'Invalid disease name',
                    'message': f'Disease "{disease_to_check}" not found. Available: {", ".join(ALL_CLASSES[1:])}'
                }), 400
            
            # Run remaining models (excluding the checked disease)
            print("🔮 Running inference on remaining models...")
            remaining_predictions = predict_with_remaining_models(img_array, disease_to_check)
            
            print(f"\n✅ Primary Result: {primary_result['status']} for {primary_result['disease_name']} ({primary_result['confidence']:.2%})")
            
            return jsonify({
                'success': True,
                'primary_result': {
                    'disease': primary_result['disease_name'],
                    'status': primary_result['status'],  # 'Normal' or 'Positive'
                    'predicted_class': primary_result['predicted_class'],
                    'confidence': primary_result['confidence']
                },
                'remaining_predictions': remaining_predictions,  # Other diseases only
                'model_info': {
                    'input_size': '224x224',
                    'checked_disease': primary_result['disease_name']
                }
            })
        else:
            # Run prediction on all models (original behavior)
            print("🔮 Running inference on all models...")
            prediction_results = predict_with_all_models(img_array)

            # Get results
            predicted_class = prediction_results['predicted_class']
            confidence = prediction_results['confidence']
            probabilities = prediction_results['probabilities']

            # Sort probabilities by value
            sorted_probs = dict(sorted(
                probabilities.items(),
                key=lambda x: x[1],
                reverse=True
            ))

            print(f"\n✅ Final Prediction: {predicted_class} ({confidence:.2%})")
            print(f"   Top 3 predictions:")
            for i, (name, prob) in enumerate(list(sorted_probs.items())[:3]):
                print(f"   {i+1}. {name}: {prob:.2%}")

            return jsonify({
                'success': True,
                'predicted_class': predicted_class,
                'confidence': confidence,
                'probabilities': sorted_probs,
                'all_probabilities': probabilities,
                'model_info': {
                    'input_size': '224x224',
                    'classes': len(ALL_CLASSES),
                    'models_used': len(models)
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
        'classes': ALL_CLASSES,
        'count': len(ALL_CLASSES)
    })

@app.route('/chat', methods=['POST'])
def chat():
    """Simple chatbot endpoint for text messages"""
    try:
        data = request.get_json()
        user_message = data.get('message', '').lower()
        # Basic rule-based response (same as frontend logic)
        if 'eye' in user_message and 'pain' in user_message:
            response = 'Eye pain can have various causes. I recommend:\n\n1. Rest your eyes from screens\n2. Apply a warm compress\n3. If pain persists, consult an eye doctor immediately.'
        elif 'exercise' in user_message or 'yoga' in user_message:
            response = 'Great! Here are some eye exercises:\n\n• 20-20-20 Rule: Every 20 min, look at something 20 feet away for 20 seconds\n• Eye Rolling: Slowly roll eyes clockwise, then counterclockwise\n• Palming: Rub hands together and place over closed eyes'
        elif 'screen' in user_message or 'computer' in user_message:
            response = 'To reduce screen strain:\n\n• Keep screen 20-26 inches away\n• Adjust brightness to match surroundings\n• Use blue light filters\n• Take regular breaks\n• Blink frequently'
        elif 'food' in user_message or 'diet' in user_message:
            response = 'Foods great for eye health:\n\n🥕 Carrots (Vitamin A)\n🥬 Leafy greens (Lutein)\n🐟 Fish (Omega-3)\n🥚 Eggs (Zinc)\n🍊 Citrus fruits (Vitamin C)'
        else:
            response = 'I understand your concern about eye health. Could you provide more details? I can help with:\n\n• Eye exercises\n• Screen time tips\n• Nutrition advice\n• Common symptoms\n• When to see a doctor'
        return jsonify({'response': response})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("=" * 70)
    print("🚀 iLab+ Eye Disease Detection API Server")
    print("   Multi-Model Architecture")
    print("=" * 70)
    print(f"Models directory: {MODELS_DIR}")
    print("")

    # Load all models on startup
    models_loaded = load_all_models()

    if models_loaded:
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
        for i, cls in enumerate(ALL_CLASSES, 1):
            print(f"   {i}. {cls}")
        print("\n" + "=" * 70)
        print("✅ Server Ready! Waiting for requests...")
        print("=" * 70)
    else:
        print("\n" + "=" * 70)
        print("⚠️  Server will start but predictions won't work")
        print("   Please check the model file paths and restart")
        print("=" * 70)

    # Start Flask server
    app.run(
        host='0.0.0.0',  # Accessible from network
        port=5000,
        debug=False,     # Set to False for production
        threaded=True
    )
