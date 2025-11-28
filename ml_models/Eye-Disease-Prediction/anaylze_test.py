import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from sklearn.metrics import confusion_matrix, classification_report
import os

# 1️⃣ Load model
model = tf.keras.models.load_model(r"D:/iLAB/eye_disease_classifier.keras")

# 2️⃣ Test directory
test_dir = r"D:/iLAB/iLab/dataset/test"

# 3️⃣ Data generator (must match training preprocessing)
test_datagen = ImageDataGenerator(rescale=1./255)

test_gen = test_datagen.flow_from_directory(
    test_dir,
    target_size=(224, 224),
    batch_size=32,
    class_mode='categorical',
    shuffle=False   # important for matching y_true with filenames
)

# 4️⃣ Class index mapping
class_indices = test_gen.class_indices
idx_to_class = {v: k for k, v in class_indices.items()}
print("Class order (class_indices):", class_indices)
print("Index → Class mapping:", idx_to_class)

# 5️⃣ Predictions
y_prob = model.predict(test_gen)
y_pred = np.argmax(y_prob, axis=1)
y_true = test_gen.classes   # ground truth labels from generator

# 6️⃣ Confusion matrix
print("\nConfusion Matrix:")
cm = confusion_matrix(y_true, y_pred)
print(cm)

# 7️⃣ Classification report (✅ fixed labels/target_names)
labels = list(range(len(idx_to_class)))              # e.g. [0,1,2,3]
target_names = [idx_to_class[i] for i in labels]     # e.g. ['Cataract','Conjunctivitis','Eyelid','Normal']

print("\nClassification Report:")
print(classification_report(y_true, y_pred, labels=labels, target_names=target_names))
