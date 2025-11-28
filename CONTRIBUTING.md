# Contributing to iLab+ Eye Health Application

Thank you for your interest in contributing to iLab+!

## Development Setup

### Prerequisites

- Flutter SDK 3.x+
- Python 3.11.9
- Git
- Android Studio / Xcode (for mobile development)

### Getting Started

1. **Fork and Clone**

   ```bash
   git clone https://github.com/YOUR_USERNAME/iLab_plus.git
   cd iLab_plus
   ```

2. **Frontend Setup**

   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```

3. **Backend Setup**

   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   python api/backend_server.py
   ```

4. **ML Models Setup**
   ```bash
   cd ml_models/Eye-Disease-Prediction
   pip install -r requirements.txt
   # Place model files in this directory
   ```

## Code Style

### Flutter/Dart

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` before committing
- Format code with `dart format .`

### Python

- Follow PEP 8
- Use type hints
- Document functions with docstrings

## Submitting Changes

1. Create a feature branch: `git checkout -b feature/your-feature-name`
2. Make your changes
3. Test thoroughly
4. Commit with clear messages: `git commit -m "Add: feature description"`
5. Push to your fork: `git push origin feature/your-feature-name`
6. Create a Pull Request

## Project Structure

```
iLab_plus/
├── frontend/     # Flutter mobile app
├── backend/      # Python API servers
└── ml_models/    # Machine learning models
```

## Reporting Issues

Use GitHub Issues with:

- Clear title
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Environment details (OS, Flutter/Python version)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
