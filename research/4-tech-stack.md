# Recommended Tech Stack

## For MVP (Minimum Viable Product)

### Frontend: Flutter
**Version:** Flutter 3.x (latest stable)

**Why Flutter?**
- Single codebase, compiles to native Android
- Hot reload for fast development iteration
- Excellent GitHub Actions support
- Strong community and documentation
- ARCore plugins available

### AR: Camera + 2D Overlay (MVP) → ARCore (v2)

**Phase 1 (MVP):**
- `camera` package for preview
- CustomPainter for 2D flight paths
- Device sensors for orientation
- Works on ALL Android devices

**Phase 2 (Optional):**
- `ar_flutter_plugin` for 3D AR
- Full ARCore integration
- Requires ARCore-compatible device

### State Management: Provider
```yaml
dependencies:
  provider: ^6.1.0
```

**Why Provider?**
- Simple, no boilerplate
- Flutter team officially recommends
- Good for MVPs
- Easy to test

### Database: SQLite (Local)
```yaml
dependencies:
  sqflite: ^2.3.0
  path_provider: ^2.1.0
```

**Why SQLite?**
- No backend server needed
- Works offline
- Fast queries
- 100 discs = ~1MB storage

### Disc Recognition: Manual + Barcode (MVP)

**Phase 1:**
- Manual disc selection from list
- Barcode scanner `mobile_scanner`
- If barcode matches → auto-select

**Phase 2:**
- `tflite` + custom model
- Image recognition (expensive to train)

### Networking: HTTP + Cache
```yaml
dependencies:
  dio: ^5.4.0
  cached_network_image: ^3.3.0
```

**For:**
- Loading disc images from URLs
- Future: disc database updates

### UI Components: Material Design 3
```yaml
dependencies:
  flutter:
    sdk: flutter
  material_color_utilities: ^0.8.0
```

**Plus:**
- `flutter_slidable` for swipe actions
- `fl_chart` for flight charts (backup visualization)

## Complete pubspec.yaml (MVP)

```yaml
name: disc_golf_ar
version: 1.0.0+1
publish_to: 'none'

description: Disc Golf AR Flight Simulator

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Core
  cupertino_icons: ^1.0.6
  provider: ^6.1.0
  
  # Database
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  
  # Camera & AR
  camera: ^0.10.5+9
  permission_handler: ^11.2.0
  ar_flutter_plugin: ^0.7.0  # Optional for v2
  
  # Sensors
  sensors_plus: ^4.0.0
  
  # Scanning
  mobile_scanner: ^3.5.0
  
  # Network & Images
  dio: ^5.4.0
  cached_network_image: ^3.3.1
  
  # Charts
  fl_chart: ^0.66.0
  
  # Utils
  vector_math: ^2.1.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.8

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/data/
```

## Development Environment

### Local Setup
```bash
# Install Flutter
flutter doctor

# Get dependencies
flutter pub get

# Run on device
flutter run

# Build APK
flutter build apk --release
```

### Recommended IDE
- **Android Studio** (best for Android development)
- **VS Code** with Flutter extension (lightweight)

## Testing

### Devices to Test
1. Modern Android 12+ (Samsung, Pixel)
2. Mid-range Android 10+ (Xiaomi, OnePlus)
3. Older Android 8+ (if possible)

### Emulators
- Android Emulator with API 29+
- ARCore image for AR testing

## GitHub Actions Build

**Workflow:** `.github/workflows/build.yml`
```yaml
name: Build Android APK

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

See file `5-github-actions.md` for complete setup.

## Architecture Patterns

### Recommended: Clean Architecture (Lightweight)

```
lib/
├── main.dart
├── app.dart
├── data/
│   ├── database/
│   │   └── disc_database.dart
│   └── models/
│       └── disc_model.dart
├── domain/
│   ├── entities/
│   └── repositories/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── viewmodels/
└── services/
    ├── flight_calculator.dart
    └── ar_service.dart
```

**Simplified for MVP:**
```
lib/
├── main.dart
├── models/
│   └── disc.dart
├── database/
│   └── disc_database.dart
├── screens/
│   ├── home_screen.dart
│   ├── disc_selection_screen.dart
│   ├── flight_simulator_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── disc_card.dart
│   ├── flight_path_painter.dart
│   └── wind_controls.dart
├── services/
│   ├── flight_simulator.dart
│   └── disc_recognizer.dart
└── providers/
    └── app_state.dart
```

## Performance Targets

- App size: <50MB (APK)
- Cold start: <3 seconds
- Flight calculation: <100ms
- Camera preview: 30fps

## Next Steps
1. Initialize Flutter project
2. Set up folder structure
3. Create database layer
4. Build UI screens
5. Implement flight simulation
6. Add camera/AR
7. Test on devices
8. GitHub Actions automation
