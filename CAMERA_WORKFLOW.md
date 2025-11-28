# AI Scan Camera Workflow

## Complete Workflow Implementation

The AI Scan feature now implements the following complete workflow:

### 1. Camera Access & Permissions

**Android Permissions (AndroidManifest.xml):**

- `android.permission.CAMERA` - Camera access
- `android.permission.READ_EXTERNAL_STORAGE` - Read images
- `android.permission.WRITE_EXTERNAL_STORAGE` - Save captured images
- `android.permission.INTERNET` - Backend API communication

**iOS Permissions (Info.plist):**

- `NSCameraUsageDescription` - Camera usage explanation
- `NSPhotoLibraryUsageDescription` - Photo library access
- `NSPhotoLibraryAddUsageDescription` - Save photos permission

### 2. Step-by-Step Workflow

```
User Opens AI Scan Screen
         ↓
┌────────────────────────┐
│ Permission Check       │
│ - Checks camera access │
│ - Shows status message │
└────────┬───────────────┘
         ↓
┌────────────────────────┐
│ User Taps Camera       │
│ - Request permission   │
│ - Handle denial        │
└────────┬───────────────┘
         ↓
┌────────────────────────┐
│ Camera Opens           │
│ - Native camera UI     │
│ - Capture eye image    │
└────────┬───────────────┘
         ↓
┌────────────────────────┐
│ Image → Cache Memory   │
│ Path: /cache/          │
│ eye_scan_[timestamp]   │
└────────┬───────────────┘
         ↓
┌────────────────────────┐
│ Auto-Analyze Trigger   │
│ - Check backend health │
└────────┬───────────────┘
         ↓
┌────────────────────────┐
│ Upload to Backend      │
│ POST /predict          │
│ multipart/form-data    │
└────────┬───────────────┘
         ↓
┌────────────────────────┐
│ Model Analysis         │
│ - Load .keras model    │
│ - Preprocess (224x224) │
│ - Run inference        │
└────────┬───────────────┘
         ↓
┌────────────────────────┐
│ Results → Frontend     │
│ - Predicted class      │
│ - Confidence %         │
│ - All probabilities    │
│ - Recommendation       │
└────────┬───────────────┘
         ↓
┌────────────────────────┐
│ Display Report         │
│ - Diagnosis            │
│ - Severity level       │
│ - Action plan          │
└────────────────────────┘
```

### 3. Status Messages During Workflow

The user sees real-time progress:

1. "Requesting camera permission..."
2. "Opening camera..."
3. "Image captured, saving to cache..."
4. "Image saved to cache. Ready to analyze."
5. "Checking backend connection..."
6. "Backend connected. Uploading image..."
7. "Image uploaded. AI model analyzing..."
8. "Analysis complete!"

### 4. Cache Management

**Location:** Device temporary directory

- Android: `/data/data/com.example.app/cache/`
- iOS: `/Library/Caches/`

**Naming:** `eye_scan_[milliseconds_timestamp].jpg`

**Cleanup:**

- Automatic cleanup when user leaves screen
- Images deleted from cache after analysis

### 5. Error Handling

**Permission Errors:**

- Denied: Show message with instructions
- Permanently Denied: Open app settings

**Camera Errors:**

- Failed to capture: Retry option
- Device has no camera: Fallback to gallery

**Backend Errors:**

- Connection failed: Show error message
- Demo mode: Runs with mock predictions

### 6. Image Specifications

**Capture Settings:**

- Max Width: 1024px
- Max Height: 1024px
- Quality: 90%
- Preferred Camera: Rear

**Backend Processing:**

- Resize to: 224x224px
- Normalization: [0, 1] range
- Format: RGB

### 7. API Communication

**Health Check:**

```http
GET http://localhost:5000/health
Response: { status, model_loaded, classes }
```

**Prediction:**

```http
POST http://localhost:5000/predict
Content-Type: multipart/form-data
Body: image file

Response: {
  success: true,
  predicted_class: "Normal Eye",
  confidence: 0.75,
  probabilities: {...},
  model_info: {...}
}
```

### 8. Setup Instructions

**Install Dependencies:**

```bash
cd frontend
flutter pub get
```

**Run Backend:**

```bash
cd backend
python api/backend_server.py
```

**Run Frontend:**

```bash
cd frontend
flutter run
```

### 9. Testing Checklist

- [ ] Camera permission request works
- [ ] Camera opens and captures image
- [ ] Image saves to cache successfully
- [ ] Backend receives image upload
- [ ] Model analyzes image correctly
- [ ] Results display on frontend
- [ ] Cache cleanup on exit
- [ ] Error handling works
- [ ] Gallery option works
- [ ] Status messages update correctly

### 10. Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 11+)
- ⚠️ Web (No camera API, gallery only)
- ⚠️ Desktop (Windows/Mac/Linux - gallery only)

## Packages Used

1. **image_picker** (^1.0.4) - Camera and gallery access
2. **permission_handler** (^11.0.1) - Permission management
3. **path_provider** (^2.1.1) - Cache directory access
4. **http** (^1.1.0) - API communication
5. **camera** (^0.10.5+5) - Advanced camera features

## Notes

- Images are automatically analyzed after capture
- Manual "Analyze Image" button available for gallery images
- Cache is automatically cleaned when leaving screen
- Backend must be running on localhost:5000
- Model paths are dynamically resolved from project structure
