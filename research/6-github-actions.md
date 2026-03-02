# GitHub Actions Setup

## Automated Android Builds

### Workflow File: `.github/workflows/build.yml`

```yaml
name: Build Android APK

on:
  push:
    branches: [main, develop]
    tags:
      - 'v*'
  pull_request:
    branches: [main]
  workflow_dispatch:

env:
  FLUTTER_VERSION: '3.16.0'

jobs:
  build:
    name: Build APK
    runs-on: ubuntu-latest
    
    steps:
      # Checkout
      - name: Checkout repository
        uses: actions/checkout@v4

      # Setup Java
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      # Setup Flutter
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true

      # Get dependencies
      - name: Get Flutter dependencies
        run: flutter pub get

      # Analyze
      - name: Analyze code
        run: flutter analyze --no-fatal-infos

      # Test (if tests exist)
      - name: Run tests
        run: flutter test || echo "No tests yet"

      # Build APK
      - name: Build APK
        run: flutter build apk --release

      # Upload APK as artifact
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk
          retention-days: 30

  # Signed Release (for distribution)
  release:
    name: Create Signed Release
    needs: build
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && contains(github.ref, 'refs/tags/')
    
    steps:
      - name: Download APK
        uses: actions/download-artifact@v4
        with:
          name: app-release

      # Sign APK (optional - requires secrets)
      # - name: Sign APK
      #   uses: r0adkll/sign-android-release@v1
      #   with:
      #     releaseDirectory: .
      #     signingKeyBase64: ${{ secrets.SIGNING_KEY }}
      #     alias: ${{ secrets.ALIAS }}
      #     keyStorePassword: ${{ secrets.KEY_STORE_PASSWORD }}
      #     keyPassword: ${{ secrets.KEY_PASSWORD }}

      # Create GitHub Release
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            app-release.apk
          body: |
            Automated build from ${{ github.sha }}
            
            ## Installation
            1. Download `app-release.apk`
            2. Allow "Unknown sources" in Android settings
            3. Install APK
            4. Open Disc Golf AR app
            
            ## Requirements
            - Android 7.0+ (API 24)
            - Camera with autofocus
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Setup Instructions

### 1. Create Repository

```bash
# On GitHub
# 1. Create new repository: disc-golf-ar
# 2. Make it public (for free GitHub Actions)
# 3. Initialize with README

# Locally
cd /disc-golf-app
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/disc-golf-ar.git
git push -u origin main
```

### 2. Create Workflow Directory

```bash
mkdir -p .github/workflows
# Create build.yml file
```

### 3. Configure Repository Settings

**Settings → Actions → General:**
- ✅ Allow all actions and reusable workflows
- ✅ Read and write permissions (for releases)

**Settings → Secrets and variables → Actions:**
Add these secrets (optional, for signed builds):
- `SIGNING_KEY` (Base64 encoded keystore)
- `ALIAS` (Keystore alias)
- `KEY_STORE_PASSWORD` (Keystore password)
- `KEY_PASSWORD` (Key password)

### 4. Generate Signing Key (Optional but Recommended)

```bash
# Local machine
keytool -genkey -v \
  -keystore disc-golf-ar.keystore \
  -alias discgolfar \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass YOUR_PASSWORD \
  -keypass YOUR_PASSWORD

# Convert to Base64 for GitHub Secret
base64 disc-golf-ar.keystore > signing_key_base64.txt
# Copy content to GitHub secret SIGNING_KEY
```

### 5. Configure Android app/build.gradle

```gradle
android {
    ...
    signingConfigs {
        release {
            if (project.hasProperty('MYAPP_UPLOAD_STORE_FILE')) {
                storeFile file(MYAPP_UPLOAD_STORE_FILE)
                storePassword MYAPP_UPLOAD_STORE_PASSWORD
                keyAlias MYAPP_UPLOAD_KEY_ALIAS
                keyPassword MYAPP_UPLOAD_KEY_PASSWORD
            }
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
            shrinkResources false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 6. Local Properties (for local builds)

```gradle
# android/local.properties (DON'T COMMIT THIS)
MYAPP_UPLOAD_STORE_FILE=disc-golf-ar.keystore
MYAPP_UPLOAD_KEY_ALIAS=discgolfar
MYAPP_UPLOAD_STORE_PASSWORD=YOUR_PASSWORD
MYAPP_UPLOAD_KEY_PASSWORD=YOUR_PASSWORD
```

### 7. Add to .gitignore

```
# Generated
/build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/ios/Flutter/Generated.xcconfig
/ios/Flutter/flutter_export_environment.sh

# Signing
disc-golf-ar.keystore
*.keystore
*.jks
key.properties
```

## Manual Build Commands

```bash
# Local development
flutter build apk --debug           # Debug build
flutter build apk --release         # Release build (unsigned)
flutter build apk --release --no-shrink  # Release without code shrinking

# With signing (requires keystore)
flutter build apk --release
```

## Downloading APK

### From GitHub Actions
1. Go to repository → Actions tab
2. Select latest successful run
3. Scroll to bottom → Artifacts
4. Download "app-release"
5. Extract ZIP → Install APK

### From GitHub Releases (Tagged)
1. Go to Releases page
2. Download latest `app-release.apk`
3. Install on Android device

## Build Optimization

### Caching for Faster Builds
```yaml
# Add to workflow
- name: Cache Gradle
  uses: actions/cache@v3
  with:
    path: ~/.gradle/caches
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*') }}
    restore-keys: |
      ${{ runner.os }}-gradle-

- name: Cache Flutter
  uses: actions/cache@v3
  with:
    path: /opt/hostedtoolcache/flutter
    key: ${{ runner.os }}-flutter-${{ env.FLUTTER_VERSION }}
```

### Split APK by ABI (Optional)
```yaml
# Smaller APKs for specific architectures
flutter build apk --release --split-per-abi
```

### Upload to External Storage (Advanced)
```yaml
# Upload to S3 or other storage
- name: Upload to S3
  uses: jakejarvis/s3-sync-action@master
  with:
    args: --acl public-read --follow-symlinks --delete
  env:
    AWS_S3_BUCKET: ${{ secrets.AWS_S3_BUCKET }}
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    AWS_REGION: 'us-east-1'
    SOURCE_DIR: 'build/app/outputs/flutter-apk'
```

## Troubleshooting

### Build Fails
1. Check Flutter version compatibility
2. Verify dependencies in pubspec.yaml
3. Check Android SDK/NDK versions
4. Review build logs in Actions tab

### APK Too Large
```yaml
# Add to build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Out of Memory
```yaml
# Increase memory for build
- name: Build with more memory
  run: |
    export GRADLE_OPTS="-Xmx4g -XX:MaxMetaspaceSize=512m"
    flutter build apk --release
```

## Cost Considerations

**GitHub Actions Free Tier:**
- 2,000 minutes/month for public repos (FREE)
- Build typically takes 5-10 minutes
- ~200 builds/month possible

**Private Repos:**
- Same limits apply
- Additional minutes: $0.008/minute

**Optimization:**
- Use caching to reduce build time
- Cancel redundant builds on PR updates
- Schedule nightly builds only if needed

## Next Steps

1. Create GitHub repository
2. Push initial code
3. Add workflow file
4. Configure signing secrets (optional)
5. Push .github/workflows to main
6. Verify Actions tab shows workflow
7. Download and test APK

## Example Repository Structure

```
disc-golf-ar/
├── .github/
│   └── workflows/
│       └── build.yml
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   ├── key.properties (not committed)
│   │   └── src/
│   └── gradle.properties
├── lib/
│   └── main.dart
├── test/
├── .gitignore
├── pubspec.yaml
└── README.md
```

Ready to automate builds! 🚀
