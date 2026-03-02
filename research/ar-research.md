# AR Implementation Research for Disc Golf App

## Overview
Augmented Reality (AR) allows users to visualize disc flight paths, course layouts, and throwing mechanics overlaid on the real world. This document covers AR frameworks suitable for a disc golf mobile application.

## Platform Comparison

### 1. Flutter + ARCore/ARKit

#### ARCore (Android) / ARKit (iOS) via Flutter
**Packages:**
- `arcore_flutter_plugin` (Android)
- `arkit_flutter_plugin` (iOS)
- `ar_flutter_plugin` (unified - community maintained)

**Pros:**
- Single Dart codebase for both platforms
- Good performance for basic AR features
- Access to native AR capabilities through platform channels
- Excellent UI development with Flutter widgets

**Cons:**
- AR plugins may lag behind native SDK updates
- Limited compared to native implementation
- iOS and Android AR features differ significantly

**Implementation Example:**
```dart
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';

class DiscGolfARView extends StatefulWidget {
  @override
  _DiscGolfARViewState createState() => _DiscGolfARViewState();
}

class _DiscGolfARViewState extends State<DiscGolfARView> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ARView(
        onARViewCreated: onARViewCreated,
        planeDetectionConfig: PlaneDetectionConfig.horizontal,
      ),
    );
  }

  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    
    // Initialize session
    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "assets/triangle.png",
      showWorldOrigin: true,
    );
    
    arObjectManager.onInitialize();
    
    // Add disc flight path visualization
    _addFlightPathVisualization();
  }
  
  void _addFlightPathVisualization() async {
    // Create flight path as a 3D curve
    var flightPathNode = ARNode(
      type: NodeType.localGLTF2,
      uri: "assets/models/flight_path.gltf",
      scale: Vector3(1, 1, 1),
      position: Vector3(0, 0.5, 0),
      rotation: Vector4(1, 0, 0, 0),
    );
    
    await arObjectManager?.addNode(flightPathNode);
  }
}
```

### 2. React Native + ViroReact / ARCore-ARKit

#### ViroReact
- **Repository**: https://github.com/ViroCommunity/viro
- **License**: MIT
- **Status**: Community maintained (originally by Viro Media)

**Pros:**
- Cross-platform AR (iOS/Android)
- Good documentation
- Supports 3D models, animations, particle effects
- JavaScript/React knowledge sufficient

**Cons:**
- Community support only (not officially maintained)
- Can be buggy with newer React Native versions
- Performance not as good as native

**Installation:**
```bash
npm install @viro-community/react-viro
```

**Example:**
```javascript
import {
  ViroARScene,
  ViroARSceneNavigator,
  ViroText,
  Viro3DObject,
  ViroMaterials,
} from "@viro-community/react-viro";

const DiscGolfScene = () => {
  const [text, setText] = useState("Initializing AR...");

  function onInitialized(state, reason) {
    if (state === ViroConstants.TRACKING_NORMAL) {
      setText("Disc Golf AR Ready!");
    }
  }

  return (
    <ViroARScene onTrackingUpdated={onInitialized}>
      <ViroText
        text={text}
        scale={[0.5, 0.5, 0.5]}
        position={[0, 0, -1]}
        style={styles.boldText}
      />
      <Viro3DObject
        source={require("./res/disc.obj")}
        position={[0, 0, -2]}
        scale={[0.1, 0.1, 0.1]}
        type="OBJ"
        animation={{ name: "flight", run: true, loop: true }}
      />
    </ViroARScene>
  );
};
```

#### React Native ARCore / ARKit
- `react-native-arcore` (Android)
- `react-native-arkit` (iOS)

**Cons:**
- Two separate implementations needed
- Less unified than ViroReact
- More native bridging code required

### 3. Unity + AR Foundation

**AR Foundation**: Unity's cross-platform AR framework
- Supports ARCore (Android) and ARKit (iOS)
- Unified API for both platforms
- Industry standard for AR games

**Pros:**
- Best-in-class AR capabilities
- Excellent 3D physics and rendering
- Large asset store with disc golf models
- Professional-grade AR features
- Can export to both platforms from single project

**Cons:**
- App size larger (Unity runtime)
- Learning curve if unfamiliar with Unity/C#
- CI/CD more complex

**Key Packages:**
- AR Foundation (core)
- ARCore XR Plugin (Android)
- ARKit XR Plugin (iOS)
- Universal Render Pipeline (performance)

**Unity Implementation Example:**
```csharp
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class DiscFlightAR : MonoBehaviour
{
    public ARRaycastManager raycastManager;
    public GameObject discPrefab;
    public GameObject flightPathPrefab;
    
    private List<ARRaycastHit> hits = new List<ARRaycastHit>();
    
    void Update()
    {
        // Detect touches to place disc flight simulation
        if (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Began)
        {
            Vector2 touchPosition = Input.GetTouch(0).position;
            
            if (raycastManager.Raycast(touchPosition, hits, TrackableType.PlaneWithinPolygon))
            {
                Pose hitPose = hits[0].pose;
                SpawnDiscFlightVisualization(hitPose.position);
            }
        }
    }
    
    void SpawnDiscFlightVisualization(Vector3 position)
    {
        // Instantiate flight path visualization
        GameObject flightPath = Instantiate(flightPathPrefab, position, Quaternion.identity);
        
        // Calculate and visualize flight arc based on disc physics
        FlightPathController controller = flightPath.GetComponent<FlightPathController>();
        controller.GenerateFlightPath(discSpeed, discGlide, discTurn, discFade);
    }
}
```

## AR Features for Disc Golf

### 1. Disc Flight Visualization
**Implementation:**
- Calculate trajectory based on flight numbers (see physics-research.md)
- Render curved path using bezier curves or particle systems
- Animate disc along path to show full flight

**Tech:**
- **Flutter**: CustomPainter + AR plugin for 3D visualization
- **React Native**: ViroParticleSystem for trail effects
- **Unity**: Trail Renderer or Particle System

### 2. Distance Measurement
**Implementation:**
- Use AR plane detection to identify ground
- Calculate distance between two points in 3D space
- Display distance overlay

**Code Example (Unity):**
```csharp
public float MeasureDistance(Vector3 pointA, Vector3 pointB)
{
    Vector3 difference = pointB - pointA;
    float distance = difference.magnitude;
    return distance; // in meters
}
```

### 3. Course Mapping
**Implementation:**
- Place virtual tee pads, baskets, and obstacles
- Store course layouts in cloud database
- Load based on GPS location

### 4. Throw Analysis
**Implementation:**
- Use device sensors (gyroscope, accelerometer)
- Track device motion during throw
- Calculate release angle, power estimate

## Performance Optimization

### General Tips
1. **Occlusion Culling**: Don't render objects behind real-world geometry
2. **LOD (Level of Detail)**: Reduce mesh complexity at distance
3. **Texture Atlasing**: Combine textures to reduce draw calls
4. **Object Pooling**: Reuse objects instead of instantiating/destroying

### Platform-Specific
- **iOS ARKit**: Use ARWorldTrackingConfiguration for best accuracy
- **Android ARCore**: Set updateRate appropriately (don't update every frame)

## GitHub Actions Compatibility

### Unity builds in CI/CD:
```yaml
# .github/workflows/build.yml
name: Build Disc Golf AR

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Cache Unity
        uses: actions/cache@v3
        with:
          path: Library
          key: Library-${{ hashFiles('Assets/**', 'Packages/**', 'ProjectSettings/**') }}
          
      - name: Build Android
        uses: game-ci/unity-builder@v2
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
        with:
          targetPlatform: Android
          
      - name: Build iOS
        uses: game-ci/unity-builder@v2
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
        with:
          targetPlatform: iOS
```

### Flutter builds:
```yaml
name: Build Flutter APK

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

## Recommendations

### For MVP (Minimum Viable Product):
**Recommended: Unity + AR Foundation**

**Why:**
1. Best AR features and stability
2. Superior physics and 3D rendering
3. Flight path visualization is core feature
4. Can leverage existing disc golf assets from Unity Asset Store
5. Single codebase for both iOS and Android

**Alternative: Flutter + ar_flutter_plugin**
- If team already knows Flutter
- Simpler setup for basic AR
- Smaller app size
- Good for simpler MVP without complex 3D

### Development Setup
1. Install Unity 2022.3 LTS with Android & iOS build support
2. Add AR Foundation packages via Package Manager
3. Configure ARKit (iOS) and ARCore (Android) plugins
4. Set up GitHub Actions with GameCI
5. Test on physical devices (AR doesn't work well on emulators)

## Useful Resources

### Unity AR Foundation
- **Docs**: https://docs.unity3d.com/Packages/com.unity.xr.arfoundation@5.1/manual/index.html
- **Samples**: https://github.com/Unity-Technologies/arfoundation-samples

### ARCore
- **Android**: https://developers.google.com/ar
- **Unity ARCore**: https://developers.google.com/ar/develop/unity

### ARKit
- **Apple**: https://developer.apple.com/augmented-reality/
- **Unity ARKit**: ARKit XR Plugin documentation

### Flutter AR
- **ar_flutter_plugin**: https://pub.dev/packages/ar_flutter_plugin
- **arkit_flutter_plugin**: https://pub.dev/packages/arkit_flutter_plugin

### Community Projects
- Search GitHub: "disc golf ar", "frisbee ar", "ar sports"
- Reddit r/UnityAR
- Unity Discs/Disc Golf assets in Asset Store
