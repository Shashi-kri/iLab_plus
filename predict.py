import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.efficientnet import preprocess_input

# Load trained model
model = tf.keras.models.load_model(r"D:\iLAB+\best_eye_model.keras")

# Class names (must match train_gen.class_indices order)
class_names = ['Conjectivites', 'Eyelid', 'Normal Eye', 'cataract', 'jaundice', 'Pterygium', 'Subconjunctival Hemorrage']

# Path to image you want to test
img_path = r"iLab\dataset\train\jaundice\image_3.jpg"  # <- change as needed

# Load and preprocess
img = image.load_img(img_path, target_size=(224, 224))
img_array = image.img_to_array(img)
img_array = np.expand_dims(img_array, axis=0)
img_array = preprocess_input(img_array)  # ✅ same as training

# Predict
pred = model.predict(img_array)
probabilities = pred[0]
pred_idx = np.argmax(probabilities)
pred_class = class_names[pred_idx]

print("Probabilities:")
for name, p in zip(class_names, probabilities):
    print(f"  {name}: {p:.4f}")

print("\nFinal Prediction:", pred_class)
