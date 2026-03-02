# Recommended Technology Stack for Disc Golf AR MVP

## Executive Summary
For a Disc Golf AR MVP with GitHub Actions CI/CD, we recommend **Unity + AR Foundation** with **Firebase** for backend services. This stack provides the best AR capabilities, cross-platform support, and automated builds.

## Recommended Stack

### 1. Development Framework: Unity 2022.3 LTS

**Why Unity:**
- Industry-leading AR support via AR Foundation
- Superior 3D physics for disc flight simulation
- Cross-platform (Android + iOS from single codebase)
- Asset Store has disc golf/3D disc models available
- Excellent GitHub Actions support via GameCI

**Version**: Unity 2022.3 LTS (Long Term Support)
- Stable, battle-tested
- AR Foundation fully supported
- Good CI/CD tooling availability

### 2. AR Framework: AR Foundation + ARCore/ARKit

**Components:**
- **AR Foundation** (core AR abstraction)
- **ARCore XR Plugin** (Android)
- **ARKit XR Plugin** (iOS)
- **XR Plugin Management**

**Key Features Needed:**
- Plane detection (ground for distance measurement)
- Raycasting (placing AR objects)
- Session management
- Camera feed access

### 3. Backend/Database: Firebase

**Services:**
- **Firestore**: Document database for disc/course data
- **Authentication**: Anonymous + Google sign-in
- **Storage**: Disc images, course photos
- **Analytics**: Usage tracking (free tier generous)

**Why Firebase:**
- Generous free tier (1M reads/day, 50k writes/day)
- Unity SDK available
- Real-time sync for multiplayer features (future)
- No server management required

**Alternative**: Supabase (PostgreSQL-based, also has generous free tier)

### 4. 3D Assets & Physics

**Assets Needed:**
- Disc 3D models (create or purchase)
- Flight path visualization shader/material
- UI prefabs for AR controls

**Physics:**
- Unity Physics (PhysX) for flight simulation
- Custom disc flight physics script (see physics-research.md)

### 5. CI/CD: GitHub Actions + GameCI

**Setup:**
- **GameCI Unity Builder**: Automated Unity builds
- **Android SDK**: For APK generation
- **Artifact storage**: GitHub releases

**Benefits:**
- Free for public repos (2000 minutes/month)
- Automatic APK generation on every push
- Test builds for PRs
- Automated distribution to Firebase App Distribution

### 6. Version Control: Git + GitHub

**Repository Structure:**
```
disc-golf-ar/
├── .github/
│   └── workflows/
│       ├── build-android.yml
│       └── build-ios.yml
├── Assets/
│   ├── Scripts/
│   ├── Prefabs/
│   ├── Scenes/
│   └── Resources/
├── Packages/
├── ProjectSettings/
└── README.md
```

**Configuration:**
- **.gitignore**: Unity-specific exclusions
- **Git LFS**: For large binary assets (textures, models)

### 7. Testing Framework: Unity Test Framework

**Components:**
- Unit tests for flight physics calculations
- Play mode tests for AR scenarios
- Integration with GitHub Actions

## Alternative Stacks Considered

### Option 2: Flutter + ARCore/ARKit

**Pros:**
- Smaller app size (no Unity runtime)
- Hot reload for faster development
- Good for simpler AR MVP

**Cons:**
- AR plugins less mature
- 3D physics limited compared to Unity
- Harder to visualize complex flight paths

**Use if**: Team already knows Flutter, simpler AR features acceptable

### Option 3: React Native + ViroReact

**Pros:**
- JavaScript ecosystem
- Cross-platform

**Cons:**
- ViroReact community-maintained only
- Can be unstable with newer RN versions
- Performance concerns

**Not recommended** for serious AR application

### Option 4: Native (Swift + Kotlin)

**Pros:**
- Maximum performance
- Full access to platform AR features

**Cons:**
- Two separate codebases to maintain
- Longer development time
- Harder to keep features in sync

**Use if**: Budget for two native developers, need cutting-edge AR

## Implementation Plan

### Phase 1: Foundation (Week 1-2)
- [ ] Install Unity 2022.3 LTS with Android/iOS modules
- [ ] Set up AR Foundation project
- [ ] Configure GitHub repository with GameCI
- [ ] Create basic AR scene with plane detection
- [ ] Successfully build APK via GitHub Actions

### Phase 2: Core Features (Week 3-4)
- [ ] Implement disc flight physics
- [ ] Create flight path visualization
- [ ] Add distance measurement
- [ ] Build disc database (local JSON initially)
- [ ] Basic UI for disc selection

### Phase 3: Backend Integration (Week 5)
- [ ] Set up Firebase project
- [ ] Integrate Firestore SDK
- [ ] Migrate disc data to cloud
- [ ] Add anonymous authentication
- [ ] Implement offline caching

### Phase 4: Polish (Week 6)
- [ ] UI/UX improvements
- [ ] Add 10-20 popular discs to database
- [ ] Test on multiple devices
- [ ] Beta release on Firebase App Distribution

### Phase 5: Launch (Week 7)
- [ ] Prepare store listings
- [ ] Create screenshots/demo video
- [ ] Submit to Play Store (Android first)
- [ ] Prepare App Store submission

## Cost Analysis

### Free Tier Limits (All services have generous free tiers)

| Service | Free Tier | MVP Usage | Cost |
|---------|-----------|-----------|------|
| GitHub Actions | 2000 min/month | ~500 min/month | $0 |
| Firebase Firestore | 1M reads/day, 50k writes/day | ~1k reads/day | $0 |
| Firebase Storage | 1GB, 10GB download/month | <100MB | $0 |
| Google Play Store | One-time fee | N/A | $25 |
| Apple App Store | Annual fee | N/A | $99/year |
| Unity | Personal license | < $100k revenue | $0 |

**Total MVP Cost**: ~$124 (one-time) + $99/year

## Team Requirements

**Minimum Team (MVP):**
1. **Unity Developer** (primary)
   - C# programming
   - Unity AR experience
   - Git/GitHub Actions experience

**Nice to Have:**
2. **UI/UX Designer** (part-time)
   - Mobile app design
   - Unity UI Toolkit knowledge

3. **3D Artist** (part-time)
   - Disc modeling
   - Animation

## Technical Dependencies

### Required SDKs/Software
- Unity 2022.3 LTS
- Android SDK (for builds)
- Xcode (for iOS builds - Mac required)
- Git
- Firebase CLI

### Unity Packages to Install
```
AR Foundation (5.x)
ARCore XR Plugin (Android)
ARKit XR Plugin (iOS)
XR Plugin Management
Input System (new)
TextMeshPro
Firebase Unity SDK (Auth, Firestore, Storage)
```

## Risk Mitigation

### Technical Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| AR not working on older devices | High | Target ARCore/ARKit compatible devices only |
| Build failures in CI | Medium | Test locally first, use GameCI proven templates |
| Large APK size | Medium | Use IL2CPP, strip unused assets |
| Firebase limits exceeded | Low | Implement caching, monitor usage |

### Device Compatibility

**Minimum Requirements:**
- **Android**: ARCore supported device (Android 8.0+)
- **iOS**: ARKit supported device (iPhone 6s+, iPad Pro+)

**Recommendation**: List supported devices explicitly in app description

## Success Metrics

**Technical:**
- [ ] GitHub Actions builds APK successfully
- [ ] App runs on 5+ test devices
- [ ] AR features work on supported devices
- [ ] Database loads < 2 seconds
- [ ] APK size < 100MB

**User:**
- [ ] Can place AR disc flight path
- [ ] Can measure distance accurately (±1 meter)
- [ ] Can browse 50+ discs in database
- [ ] App works offline

## Conclusion

**Unity + AR Foundation + Firebase + GitHub Actions** is the optimal stack for a Disc Golf AR MVP. It balances:
- Powerful AR capabilities
- Cross-platform efficiency
- Free/low-cost operation
- Automated CI/CD
- Room for future scaling

Start with Phase 1 (foundation) and iterate based on user feedback.
