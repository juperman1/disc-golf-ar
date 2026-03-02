# Disc Flight Physics Research

## Understanding Disc Flight Numbers

### The Four Numbers System
Disc golf discs use a standardized flight rating system with four numbers:
1. **Speed (1-14)** - How fast the disc must be thrown
2. **Glide (1-7)** - How long it stays in the air
3. **Turn (-5 to 1)** - High-speed stability (negative = understable/turns right for RHBH)
4. **Fade (0-5)** - Low-speed stability (higher = more fade left for RHBH)

### Example Discs
- **Innova Destroyer**: 12/5/-1/3 - High speed, moderate glide, slight turn, strong fade
- **Discraft Buzzz**: 5/4/-1/1 - Mid-range, good glide, stable
- **Dynamic Discs Judge**: 2/4/0/1 - Putter, high glide, very stable

## Physics Behind Disc Flight

### Key Physical Forces
1. **Lift** - Created by disc shape (airfoil), keeps disc airborne
2. **Drag** - Air resistance, slows disc down
3. **Gyroscopic Effect** - Spin stabilizes the disc in flight
4. **Torque** - Applied by thrower determines initial angle

### Flight Phases
1. **High Speed Turn**: Disc curves right (for RHBH) at high velocity
2. **Cruise**: Maintains straight line at optimal speed
3. **Low Speed Fade**: Curves left as it loses velocity
4. **Finish**: Disc falls off to the left

### Wind Effects
- **Headwind**: Increases effective speed, more turn
- **Tailwind**: Decreases effective speed, more fade
- **Crosswind**: Pushes disc laterally, complex interactions

## Simulation Approach

### Simplified Physics Model
```javascript
// Pseudocode for disc flight
function simulateFlight(speed, glide, turn, fade, windSpeed, windDirection, throwPower) {
  const duration = calculateAirTime(speed, glide);
  const turnAmount = calculateTurn(turn, throwPower, wind);
  const fadeAmount = calculateFade(fade, throwPower, wind);
  
  return generateFlightPath(turnAmount, fadeAmount, duration);
}
```

### Parameters to Model
- Release velocity (0-100% power)
- Release angle (nose up/down)
- Release height
- Wind vector (speed + direction)
- Spin rate (affects stability)
- Disc wear (beat in vs. new)

## Existing Research Sources

### Academic Papers
- "Aerodynamics of a Flying Disc" by various authors
- PDGA technical specifications
- Disc manufacturer patent filings

### Open Source Projects
- Flight Analyser algorithms (reverse engineered)
- Disc golf flight calculators (JavaScript/Python implementations)
- CFD simulations (minimal, mostly proprietary)

### Practical Data
- Manufacturer flight charts
- Community flight reviews (InfiniteDiscs, Marshall Street)
- Tournament flight data (limited)

## MVP Physics Approach

For initial implementation:
1. Use simplified bezier curves based on flight numbers
2. Wind affects turn/fade multipliers
3. Don't calculate actual fluid dynamics (too complex)
4. Focus on visual representation
5. Allow user adjustment of throw power

## Next Steps
- Implement basic flight curve generation
- Add wind vector calculations
- Create test cases with known discs
- Iterate based on user feedback
