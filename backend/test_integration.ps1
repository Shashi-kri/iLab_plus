# Quick Test Script
# Tests the AI integration without needing the actual model file

Write-Host "================================" -ForegroundColor Cyan
Write-Host "  iLab+ AI Integration Test" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check dependencies
Write-Host "1. Checking dependencies..." -ForegroundColor Yellow
Push-Location C:\ilab+\flutter-1\ilab_plus_app
$pubspecExists = Test-Path "pubspec.yaml"
if ($pubspecExists) {
    Write-Host "   ✓ pubspec.yaml found" -ForegroundColor Green
} else {
    Write-Host "   ✗ pubspec.yaml not found" -ForegroundColor Red
    exit 1
}

# Check if dependencies are installed
Write-Host ""
Write-Host "2. Checking Flutter packages..." -ForegroundColor Yellow
$pluginsFile = ".flutter-plugins-dependencies"
if (Test-Path $pluginsFile) {
    Write-Host "   ✓ Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "   ! Running flutter pub get..." -ForegroundColor Yellow
    flutter pub get
}

# Check file structure
Write-Host ""
Write-Host "3. Checking file structure..." -ForegroundColor Yellow

$requiredFiles = @(
    "lib\services\model_service.dart",
    "lib\services\api_service.dart",
    "lib\screens\ai_scan_screen.dart",
    "scripts\convert_model_to_tflite.py",
    "scripts\api_server.py",
    "assets\models\labels.txt"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "   ✗ $file" -ForegroundColor Red
    }
}

# Check for model file
Write-Host ""
Write-Host "4. Checking model file..." -ForegroundColor Yellow
$modelFile = "assets\models\eye_disease_model.tflite"
if (Test-Path $modelFile) {
    $sizeBytes = (Get-Item $modelFile).Length
    $sizeMB = [math]::Round($sizeBytes / 1MB, 2)
    Write-Host "   ✓ Model found ($sizeMB MB)" -ForegroundColor Green
} else {
    Write-Host "   ✗ Model not found (will use demo mode)" -ForegroundColor Yellow
    Write-Host "     Run: python scripts\convert_model_to_tflite.py" -ForegroundColor Gray
}

# Test run
Write-Host ""
Write-Host "5. Testing app..." -ForegroundColor Yellow
Write-Host "   Starting Flutter app on Chrome..." -ForegroundColor Cyan
Write-Host ""

# Launch app
flutter run -d chrome

Pop-Location
