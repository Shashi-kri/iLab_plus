import io
import numpy as np
from PIL import Image

import tensorflow as tf
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from tensorflow.keras.applications.efficientnet import preprocess_input

# Load trained model
MODEL_PATH = r"D:/iLAB/eye_disease_classifier.keras"
model = tf.keras.models.load_model(MODEL_PATH)

# ⚠ The correct class order (based on your training data)
class_names = [
    "Conjectivites",
    "Eyelid",
    "Normal Eye",
    "cataract"
]

IMG_SIZE = (224, 224)

app = FastAPI()

# Allow any app / mobile to access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def preprocess_image(file_bytes: bytes):
    img = Image.open(io.BytesIO(file_bytes)).convert("RGB")
    img = img.resize(IMG_SIZE)

    x = np.array(img, dtype=np.float32)
    x = np.expand_dims(x, axis=0)
    x = preprocess_input(x)
    return x

@app.get("/")
def home():
    return {"message": "Eye Disease Classifier API is running", "classes": class_names}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    file_bytes = await file.read()
    x = preprocess_image(file_bytes)

    preds = model.predict(x)
    probs = preds[0]

    pred_idx = int(np.argmax(probs))
    pred_class = class_names[pred_idx]

    prob_dict = {class_names[i]: float(probs[i]) for i in range(len(class_names))}

    return {
        "filename": file.filename,
        "predicted_index": pred_idx,
        "predicted_class": pred_class,
        "probabilities": prob_dict
    }
