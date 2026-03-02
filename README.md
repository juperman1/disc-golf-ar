# Disc Golf AR - Flight Simulator

An Android app for disc golfers to visualize disc flight paths based on wind conditions and throw power.

## Features

- 📱 **20 Popular Discs** - Innova, Discraft, Dynamic Discs, and more
- 🎯 **Flight Simulation** - Simplified physics model using PDGA flight numbers
- 💨 **Wind Control** - Adjust wind speed and direction
- 💪 **Power Slider** - Simulate different throw strengths
- 📊 **Visual Flight Path** - See where your disc will fly
- 🔄 **RHBH/LHBH** - Support for right and left hand backhand

## Installation

### From GitHub Actions
1. Go to [Actions](../../actions) tab
2. Select the latest successful run
3. Download `disc-golf-ar-app` artifact
4. Extract the APK
5. Allow "Unknown sources" in Android settings
6. Install APK

### Requirements
- Android 7.0+ (API level 24)
- Camera with autofocus for barcode scanning (coming soon)

## Usage

1. **Select a Disc**: Browse the database of 20 popular discs
2. **Adjust Power**: Set your throw strength (30-100%)
3. **Set Wind Conditions**: Front, back, left, or right wind
4. **See Flight**: View the projected flight path

## Tech Stack

- **Flutter** 3.x - Cross-platform framework
- **Provider** - State management
- **Custom Paint** - Flight visualization
- **GitHub Actions** - Automatic APK builds

## Flight Physics

The app uses a simplified disc flight model based on:
- **Speed (1-14)**: Disc's required velocity
- **Glide (1-7)**: How long it stays airborne  
- **Turn (-5 to 1)**: High-speed stability (negative = right turn for RHBH)
- **Fade (0-5)**: Low-speed stability

## Roadmap

### MVP (Current)
- [x] 20 disc database
- [x] Flight simulation
- [x] Wind controls
- [x] Visual flight path

### Phase 2
- [ ] Barcode scanning for discs
- [ ] Camera AR view
- [ ] Database expansion to 100+ discs
- [ ] Disc comparison

### Phase 3
- [ ] Full ARCore integration
- [ ] Course mapping
- [ ] Shot tracking statistics
- [ ] Social sharing

## Development

### Local Setup
```bash
flutter pub get
flutter run
```

### Build APK
```bash
flutter build apk --release
```

## License

MIT License - Open source!

## Credits

Developed with Flutter and ❤️
