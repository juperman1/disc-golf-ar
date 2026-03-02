# AR Implementation Research

## Mobile AR Framework Options

### Option 1: Flutter + ARCore (Recommended)

**Why Flutter?**
- ✅ Single codebase for iOS and Android
- ✅ Hot reload for fast development
- ✅ GitHub Actions builds work well
- ✅ Good plugin ecosystem
- ✅ Backed by Google

**ARCore Integration**
- Package: `ar_flutter_plugin` or `arcore_flutter_plugin`
- ARCore is Google's AR framework for Android
- Features: Motion tracking, environmental understanding, light estimation
- Works on 100M+ Android devices

**Pros:**
- Fastest development
- Build automation works
- Native performance via platform channels
- Good documentation

**Cons:**
- Platform channel complexity
- Limited advanced AR features
- iOS support requires ARKit

### Option 2: React Native + ARCore

**Packages:** 
- `@react-native-ar-kit`
- `react-native-arcore`

**Pros:**
- JavaScript ecosystem
- Large community

**Cons:**
- More complex bridge setup
- Performance overhead
- Build can be tricky in CI/CD

### Option 3: Unity + AR Foundation

**AR Foundation:**
- Unified API for ARCore (Android) and ARKit (iOS)
- Most powerful AR capabilities
- Industry standard for AR games

**Pros:**
- Maximum AR features
- Best visual quality
- Physics engine included
- Asset Store resources

**Cons:**
- ❌ Larger app size (>100MB)
- ❌ Slower GitHub Actions builds
- ❌ Overkill for simple flight paths
- ❌ Requires Unity license understanding
- ❌ Harder to customize UI

**Verdict:** Too heavy for MVP

### Option 4: Native Kotlin + ARCore

**Pros:**
- Maximum performance
- Direct Android SDK access

**Cons:**
- ❌ No iOS compatibility
- ❌ More code to maintain
- ❌ Harder for open source contributors

## Recommended: Flutter + ARCore

### Technical Implementation

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  ar_flutter_plugin: ^0.7.0
  vector_math: ^2.1.0
  sensors_plus: ^3.0.0
```

### Core AR Features Needed

1. **Plane Detection**
   - Detect ground planes
   - Place disc flight origin

2. **Line Rendering**
   - Draw curved flight paths in 3D
   - Adjust based on throw parameters

3. **Camera Feed**
   - Background video from camera
   - Overlay AR graphics on top

4. **Touch/Gesture**
   - Rotate view
   - Adjust flight parameters
   - Tap to place anchor

### Simplified Approach for MVP

**Instead of full AR:**
1. Camera view as background
2. Draw 2D flight curve on screen
3. Use device orientation for "AR-like" effect
4. Simpler to implement
5. Works without ARCore on older devices

**Hybrid Approach:**
- Basic: 2D flight path overlay on camera
- Advanced: Full ARCore 3D placement
- Fallback for non-AR devices

## ARCore Device Compatibility

### Requirements
- Android 7.0+ (API level 24)
- ARCore supported device (check list: developers.google.com/ar/devices)
- Camera with autofocus
- Gyroscope

### Coverage
- ~1000+ Android devices
- ~85% of active Android devices
- Check: `arcore_flutter_plugin` availability check

## Alternative: No ARCore

**Pure Camera + Overlay:**
- No special hardware needed
- Works on all Android devices
- Draw flight paths as 2D curves
- Use accelerometer for rough orientation
- Less immersive but more compatible

**Recommendation:**
Start with camera overlay, add ARCore as optional enhancement.

## Visual Design

### Flight Path Visualization
1. **Color-coded by height**: Green (low) to Red (high)
2. **Animated trajectory**: Disc "flies" along path
3. **Wind indicators**: Arrows showing wind direction
4. **Distance markers**: Show distance at intervals

### UI Overlay
- Button: "Scan Disc" (camera)
- Slider: Throw power (0-100%)
- Slider: Wind speed
- Picker: Wind direction
- Button: "Simulate Flight"
- Display: Disc info, expected flight

## Technical Implementation Plan

### Phase 1: Camera + 2D (MVP)
- Camera preview as background
- 2D Bezier curves for flight path
- No ARCore required
- Works on all Android devices

### Phase 2: Basic ARCore (v2)
- Ground plane detection
- 3D flight path in space
- Place virtual disc at landing

### Phase 3: Full AR (v3)
- Multi-angle viewing
- Persist flight paths
- Share screenshots

## Next Steps
1. Implement camera + 2D overlay first
2. Test on multiple devices
3. Add ARCore as optional feature
4. Gather user feedback
5. Iterate on visualization
