# Flutter Setup Files

Essential files to run the Flutter application:

## Platform-Specific Files

- `android/` - Android native configuration
- `ios/` - iOS native configuration
- `web/` - Web platform support
- `windows/` - Windows desktop support
- `linux/` - Linux desktop support
- `macos/` - macOS desktop support

## Assets

- `assets/` - Images, fonts, and other resources
- `assets/images/color_blindness/` - Ishihara test plates

## Configuration

- `pubspec.yaml` - Flutter dependencies
- `analysis_options.yaml` - Dart linter rules
- `.metadata` - Flutter project metadata

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build for production
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
flutter build windows    # Windows
```

## Required Flutter SDK

- Flutter 3.x+
- Dart 3.x+

Install from: https://flutter.dev/docs/get-started/install
