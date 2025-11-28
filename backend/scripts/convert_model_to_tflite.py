"""
Convert TensorFlow Keras model to TensorFlow Lite format
Usage: python convert_model_to_tflite.py

This script converts the eye disease classification model from Keras format
to TensorFlow Lite format for use in Flutter mobile app.
"""

import tensorflow as tf
import numpy as np
import os

# Configuration
MODEL_PATH = r"D:/iLAB+/best_eye_model.keras"  # Update this path
OUTPUT_PATH = r"../assets/models/eye_disease_model.tflite"
OUTPUT_LABELS_PATH = r"../assets/models/labels.txt"

# Class names (must match training order)
CLASS_NAMES = [
    'Conjectivites',
    'Eyelid',
    'Normal Eye',
    'cataract',
    'Pterygium'
]

def convert_model():
    """Convert Keras model to TensorFlow Lite format"""

    print("=" * 60)
    print("TensorFlow Lite Model Converter")
    print("=" * 60)

    # Check if model exists
    if not os.path.exists(MODEL_PATH):
        print(f"❌ Error: Model not found at {MODEL_PATH}")
        print(f"Please update MODEL_PATH in this script to point to your model file")
        return False

    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)

    # Load the Keras model
    print(f"\n📦 Loading model from: {MODEL_PATH}")
    model = tf.keras.models.load_model(MODEL_PATH)
    print("✅ Model loaded successfully")

    # Print model summary
    print("\n📊 Model Summary:")
    model.summary()

    # Convert to TensorFlow Lite
    print("\n🔄 Converting to TensorFlow Lite format...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)

    # Optional: Apply optimizations
    converter.optimizations = [tf.lite.Optimize.DEFAULT]

    # Optional: Set supported operations (if needed)
    # converter.target_spec.supported_ops = [
    #     tf.lite.OpsSet.TFLITE_BUILTINS,
    #     tf.lite.OpsSet.SELECT_TF_OPS
    # ]

    # Convert the model
    tflite_model = converter.convert()
    print("✅ Conversion successful")

    # Save the model
    print(f"\n💾 Saving TFLite model to: {OUTPUT_PATH}")
    with open(OUTPUT_PATH, 'wb') as f:
        f.write(tflite_model)

    # Get model size
    model_size = os.path.getsize(OUTPUT_PATH)
    print(f"✅ Model saved successfully")
    print(f"📏 Model size: {model_size / (1024 * 1024):.2f} MB")

    # Save labels
    print(f"\n💾 Saving labels to: {OUTPUT_LABELS_PATH}")
    with open(OUTPUT_LABELS_PATH, 'w') as f:
        for label in CLASS_NAMES:
            f.write(label + '\n')
    print("✅ Labels saved successfully")

    # Test the model
    print("\n🧪 Testing the converted model...")
    test_inference(OUTPUT_PATH)

    print("\n" + "=" * 60)
    print("✅ Conversion Complete!")
    print("=" * 60)
    print(f"\nNext steps:")
    print(f"1. Copy {OUTPUT_PATH} to your Flutter app's assets/models/ folder")
    print(f"2. Copy {OUTPUT_LABELS_PATH} to your Flutter app's assets/models/ folder")
    print(f"3. Update pubspec.yaml to include assets/models/")
    print(f"4. Run 'flutter pub get' to install dependencies")
    print(f"5. The model is ready to use in your Flutter app!")

    return True

def test_inference(model_path):
    """Test the TFLite model with a dummy input"""
    try:
        # Load TFLite model
        interpreter = tf.lite.Interpreter(model_path=model_path)
        interpreter.allocate_tensors()

        # Get input and output details
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()

        print(f"  Input shape: {input_details[0]['shape']}")
        print(f"  Output shape: {output_details[0]['shape']}")

        # Create dummy input (224x224x3 image)
        input_shape = input_details[0]['shape']
        dummy_input = np.random.random(input_shape).astype(np.float32)

        # Run inference
        interpreter.set_tensor(input_details[0]['index'], dummy_input)
        interpreter.invoke()

        # Get output
        output = interpreter.get_tensor(output_details[0]['index'])
        predicted_class = np.argmax(output[0])
        confidence = output[0][predicted_class]

        print(f"  ✅ Test inference successful")
        print(f"  Sample prediction: {CLASS_NAMES[predicted_class]} ({confidence:.2%})")

    except Exception as e:
        print(f"  ❌ Test inference failed: {str(e)}")

if __name__ == "__main__":
    try:
        success = convert_model()
        if success:
            print("\n🎉 All done! Your model is ready for Flutter integration.")
        else:
            print("\n❌ Conversion failed. Please check the error messages above.")
    except Exception as e:
        print(f"\n❌ Error during conversion: {str(e)}")
        import traceback
        traceback.print_exc()
