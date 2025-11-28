# iLab+ Eye Health Application

A comprehensive Flutter-based eye health application with AI-powered disease detection and multiple vision tests.

## Project Structure

```
iLab_plus/
├── frontend/                    # Dart Flutter Mobile App
│   ├── lib/
│   │   ├── screens/            # 13+ vision test screens
│   │   ├── theme/              # UI theming
│   │   ├── data/               # Data models
│   │   └── main.dart           # App entry point
│   ├── pubspec.yaml
│   ├── android/                # Android native code
│   ├── ios/                    # iOS native code
│   └── ...
│
├── backend/                     # Python APIs & Services
│   ├── api/                    # FastAPI/Flask servers
│   │   ├── backend_server.py   # Main API server
│   │   └── api_11.py           # Alternative Flask API
│   ├── scripts/                # Python utilities
│   │   ├── api_server.py       # Additional API implementation
│   │   └── convert_model_to_tflite.py  # Model conversion
│   ├── tests/                  # Integration tests
│   │   └── test_integration.ps1
│   ├── requirements.txt        # Python dependencies
│   └── README.md
│
├── ml_models/                   # Machine Learning Models
│   ├── trained_models/         # Keras model files
│   │   ├── eye_disease_classifier.keras
│   │   └── best_eye_model.keras
│   ├── eye_disease_prediction/ # ML utilities & analysis
│   │   ├── api.py             # FastAPI prediction server
│   │   ├── predict.py         # Prediction utilities
│   │   ├── training.py        # Model training
│   │   └── data_augmentation.py
│   └── README.md
│
├── docs/                        # Documentation
├── .gitignore
└── README.md
```

## Features

### Frontend (Flutter)

- **Vision Tests:**

  - Visual Acuity Test
  - Color Blindness Test (Ishihara)
  - Astigmatism Test
  - Dry Eye Test
  - AI-Powered Disease Detection

- **User Features:**
  - Dashboard with test history
  - Reports and results summary
  - Chatbot support
  - Suggested actions based on results

### Backend (Python)

- FastAPI/Flask REST APIs
- Eye disease classification
- Real-time predictions
- CORS-enabled for mobile integration

### ML Models

- EfficientNetB0 architecture
- 4-class disease classification:
  - Conjunctivitis
  - Eyelid diseases
  - Normal eye
  - Cataract
- TensorFlow 2.15.0+

## Setup Instructions

### Frontend Setup

```bash
cd frontend
flutter pub get
flutter run
```

### Backend Setup

```bash
cd backend
pip install -r requirements.txt
python api/backend_server.py
```

### ML Models

```bash
cd ml_models
pip install -r requirements.txt
python predict.py <image_path>
```

## Dependencies

### Python (Backend & ML)

- Flask 3.0.0
- FastAPI
- TensorFlow 2.15.0
- Pillow 10.1.0
- NumPy 1.26.4+
- Flask-CORS 4.0.0

### Dart/Flutter

- Flutter SDK
- Dart 3.x+
- See `frontend/pubspec.yaml` for full list

## API Endpoints

### Main Server (`/predict`)

```
POST /predict
Content-Type: multipart/form-data
Body: { file: <image> }

Response:
{
  "predicted_class": "cataract",
  "confidence": 0.95,
  "all_probabilities": {
    "Conjunctivitis": 0.02,
    "Eyelid": 0.01,
    "Normal Eye": 0.02,
    "cataract": 0.95
  }
}
```

### Health Check (`/health`)

```
GET /health
Response: { "status": "healthy" }
```

## Contributing

Follow the folder structure conventions when adding new features.

## License

MIT License - See LICENSE file

## Contact

For issues or questions, contact the development team.
