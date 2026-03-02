# MVP Project Plan

## Vision
An Android app that lets disc golfers scan disc golf discs via camera and visualize their flight paths in augmented reality, including wind conditions and throw power adjustments.

## MVP Scope

### What MVP Includes
✅ Database of 100 most popular discs
✅ Manual disc selection (no AI recognition yet)
✅ Basic barcode scanning
✅ Camera preview with 2D flight path overlay
✅ Wind speed and direction settings
✅ Throw power slider
✅ Simple flight visualization (2D curves)
✅ Disc details page (flight numbers, description)

### What MVP Does NOT Include
❌ AI disc recognition from photos
❌ 3D ARCore integration (Phase 2)
❌ Full disc database (2000+ discs)
❌ Social features / sharing
❌ Cloud sync
❌ iOS version (Android only MVP)

## Timeline: 4-6 Weeks

### Week 1: Foundation
**Day 1-2: Project Setup**
- [ ] Initialize Flutter project
- [ ] Set up folder structure
- [ ] Add dependencies to pubspec
- [ ] Configure GitHub Actions basic workflow
- [ ] Create README with setup instructions

**Day 3-4: Database**
- [ ] Design database schema
- [ ] Initialize SQLite database
- [ ] Create Disc model class
- [ ] Implement CRUD operations
- [ ] Seed database with 20 discs (test data)

**Day 5-7: UI Skeleton**
- [ ] Create main app structure
- [ ] Bottom navigation (Home, Discs, Simulator, Settings)
- [ ] Basic screens layout
- [ ] Navigation routing
- [ ] App state management (Provider)

### Week 2: Core Features
**Day 8-10: Disc Database**
- [ ] Complete disc data entry (100 discs)
- [ ] Disc list screen with search
- [ ] Disc detail screen
- [ ] Filter by type (driver, midrange, putter)
- [ ] Sort by flight numbers

**Day 11-12: Barcode Scanner**
- [ ] Integrate mobile_scanner package
- [ ] Barcode lookup (use GTIN database if available)
- [ ] Fallback to manual selection
- [ ] Test with real discs

**Day 13-14: Flight Physics**
- [ ] Implement flight calculation algorithm
- [ ] Create FlightPath model
- [ ] Generate bezier curves from flight numbers
- [ ] Add wind factor calculations
- [ ] Test with known disc flights

### Week 3: AR/Camera Features
**Day 15-17: Camera Integration**
- [ ] Add camera permission handling
- [ ] Camera preview screen
- [ ] Proper permission UI (explain why)
- [ ] Handle camera errors gracefully

**Day 18-20: Flight Visualization**
- [ ] Create FlightPathPainter (CustomPaint)
- [ ] Draw curved flight paths on camera
- [ ] Color by height (green>yellow>red)
- [ ] Animate disc along path
- [ ] Show distance markers

**Day 21: Wind & Power Controls**
- [ ] Wind direction picker
- [ ] Wind speed slider
- [ ] Throw power slider
- [ ] Real-time flight update
- [ ] Preset buttons (RHBH, LHBH, forehand)

### Week 4: Testing & Polish
**Day 22-24: Testing**
- [ ] Test on 3 different Android devices
- [ ] Fix camera aspect ratio issues
- [ ] Optimize performance
- [ ] Memory leak check
- [ ] Database integrity test

**Day 25-26: UI Polish**
- [ ] Loading states
- [ ] Error messages (user-friendly)
- [ ] Animations and transitions
- [ ] Dark mode support
- [ ] Accessibility improvements

**Day 27-28: GitHub Actions**
- [ ] Set up automated builds
- [ ] APK signing configuration
- [ ] Test GitHub release workflow
- [ ] Document download process

### Week 5-6: Buffer & Improvements
**Remaining time for:**
- Bug fixes
- Additional disc data
- Performance optimization
- User feedback implementation
- App store preparation (if desired)
- Documentation

## Milestones

### Milestone 1: Foundation (End of Week 1)
✅ App launches without errors
✅ Database with 100 discs
✅ Navigation between screens works
🎉 **Downloadable APK via GitHub Actions**

### Milestone 2: Core Features (End of Week 2)
✅ Complete disc database
✅ Search and filter work
✅ Barcode scanning functional
✅ Flight calculations accurate
🎉 **Usable for disc selection**

### Milestone 3: AR Features (End of Week 3)
✅ Camera preview works
✅ Flight paths visible on camera
✅ Wind/power controls functional
✅ Smooth animations
🎉 **Full feature set working**

### Milestone 4: Release (End of Week 4)
✅ Stable on multiple devices
✅ No critical bugs
✅ GitHub Actions automated builds
✅ Documentation complete
🎉 **MVP ready for use!**

## Definition of Done

### Feature Complete
- [ ] All MVP features implemented
- [ ] No placeholder screens
- [ ] Loading states handled
- [ ] Error messages informative
- [ ] Database seeded with 100 discs

### Quality
- [ ] App size <50MB
- [ ] Start time <3 seconds
- [ ] No crashes on tested devices
- [ ] 60fps animations
- [ ] Memory usage <200MB

### UX
- [ ] Intuitive navigation
- [ ] Clear feedback for actions
- [ ] Helpful empty states
- [ ] Consistent design
- [ ] Works without internet

### DevOps
- [ ] GitHub Actions builds APK
- [ ] Signed APK downloadable
- [ ] README with instructions
- [ ] CHANGELOG started
- [ ] MIT license chosen

## Week-by-Week Commitments

**Week 1 Commit:**
"Foundation: Flutter project, database, navigation"

**Week 2 Commit:**
"Core: 100 discs, barcode scanner, flight physics"

**Week 3 Commit:**
"AR: Camera, flight visualization, controls"

**Week 4 Commit:**
"Release: Tested, polished, documented"

## Risk Mitigation

### Technical Risks
| Risk | Mitigation |
|------|------------|
| ARCore not working on device | Fallback to 2D camera overlay |
| Camera permission denied | Clear explanation, settings link |
| Database too big for APK | Lazy load images from network |
| Build fails in GitHub Actions | Test locally first, simplify |

### Time Risks
| Risk | Mitigation |
|------|------------|
| Feature takes longer than planned | Cut scope (remove nice-to-have) |
| Third-party package issues | Have backup package selected |
| Testing requires many devices | Start with emulator + 1 device |

### Success Criteria
✅ User can:
1. Find their disc in the database
2. See flight numbers
3. Open camera
4. Set wind conditions
5. See projected flight path
6. Adjust power and see changes
7. Download APK from GitHub

## Post-MVP Ideas

### Phase 2 (Months 2-3)
- ARCore 3D placement
- Image recognition (disc scanning)
- Full database (2000+ discs)
- Disc comparison tool

### Phase 3 (Months 4-6)
- Course mapping
- GPS integration
- Shot tracking
- Statistics
- Social sharing

### Phase 4 (Future)
- iOS version
- Cloud sync
- Community-driven features
- Tournament integration

## Next Steps

**This Week:**
1. Review this plan
2. Initialize Flutter project
3. Set up GitHub repository
4. Configure GitHub Actions
5. Start database design

**Questions to Answer:**
- Which 100 discs to include first?
- Priority order for features?
- Target Android version (API level)?
- Should we support tablets?

Ready to start? 🚀
