# Disc Golf Flight Physics Research

## Overview
Disc golf discs are engineered aerodynamic objects that follow specific flight patterns based on their design characteristics. Understanding these physics is essential for an AR disc golf app to accurately simulate disc flight.

## The Four Flight Numbers System

Disc manufacturers use a standardized four-number rating system to describe disc flight characteristics:

### 1. Speed (1-14)
- **Definition**: The disc's ability to cut through the air and maintain velocity
- **Higher values**: More aerodynamic, require more arm speed to achieve optimal flight
- **Lower values**: Slower, easier to control, better for beginners
- **Physical basis**: Relates to the disc's rim width and aerodynamic profile
- **Math**: Speed rating correlates with rim thickness; higher speed = wider rim

### 2. Glide (1-7)
- **Definition**: The disc's ability to maintain loft during flight
- **Higher values**: Stay aloft longer, travel farther with less power
- **Lower values**: Drop more quickly, better for controlled approaches
- **Physical basis**: Lift-to-drag ratio, determined by the disc's dome shape and bottom profile

### 3. Turn (-5 to +1)
- **Definition**: The disc's tendency to curve right (for RHBH throwers) during the high-speed initial phase
- **Negative values**: More understable, will turn right significantly (good for turnover shots)
- **Zero/Positive**: Stable to overstable, resist turning (straight to left finish)
- **Physical basis**: Relationship between center of lift and center of gravity
- **Physics**: High-speed turn is caused by aerodynamic lift forces creating a moment when the disc is spinning rapidly

### 4. Fade (0-5)
- **Definition**: The disc's tendency to curve left (for RHBH throwers) at the end of flight as it slows down
- **Higher values**: Strong fade, finish hard left
- **Lower values**: Minimal fade, straighter finish
- **Physical basis**: Same aerodynamic forces as turn, but become dominant as rotational velocity decreases

## Flight Phase Physics

### Phase 1: High-Speed (Turn Phase)
- Disc is spinning at maximum RPM
- Gyroscopic effects are strong
- Aerodynamic forces dominate at outer rim
- Turn rating determines behavior
- Lasts approximately 30-50% of total flight

### Phase 2: Mid-Speed (Straight/Cruising Phase)
- Disc reaches equilibrium between gyroscopic and aerodynamic forces
- Most efficient flight path
- Glide rating determines distance potential here

### Phase 3: Low-Speed (Fade Phase)
- Rotational velocity decreases
- Precession becomes more pronounced
- Fade rating determines finishing direction
- Disc falls naturally due to gravity

## Mathematical Models

### Basic Flight Equations
```
Lift Force: L = ½ * ρ * v² * A * CL
Drag Force: D = ½ * ρ * v² * A * CD
Moment: M = L * d (where d is moment arm)
```

Where:
- ρ = air density
- v = velocity
- A = planform area
- CL = lift coefficient (varies with angle of attack)
- CD = drag coefficient

### Simplified Simulation Model
For an MVP AR app, use this simplified approach:

```javascript
// Pseudo-code for disc flight simulation
class DiscFlight {
  constructor(speed, glide, turn, fade) {
    this.speed = speed;    // 1-14
    this.glide = glide;    // 1-7
    this.turn = turn;      // -5 to 1
    this.fade = fade;      // 0-5
  }

  calculateFlightPath(releaseVelocity, releaseAngle, throwPower) {
    // Normalize throw power (0-100%) to disc speed requirement
    const powerRatio = throwPower / (this.speed * 7.14); // 100% = speed 14
    
    // Turn calculation (high-speed phase)
    const turnAmount = this.turn * powerRatio * 0.3; // in meters
    
    // Fade calculation (low-speed phase)
    const fadeAmount = this.fade * (1 - powerRatio) * 0.5; // in meters
    
    // Distance based on speed + glide + power
    const baseDistance = this.speed * this.glide * 10; // meters
    const actualDistance = baseDistance * powerRatio;
    
    return {
      distance: actualDistance,
      turn: turnAmount,
      fade: fadeAmount,
      height: this.glide * 2 // rough estimate
    };
  }
}
```

## Environmental Factors

### Wind Effects
- **Headwind**: Increases effective airspeed, exaggerates turn
- **Tailwind**: Decreases effective airspeed, reduces turn, may cause early fade
- **Crosswind**: Pushes disc laterally; effects vary by disc stability

### Weight Considerations
- Standard disc weights: 150-180g
- Lighter discs: More affected by wind, turn more easily
- Heavier discs: More wind-resistant, maintain stability better

## Disc Types and Their Physics

| Type | Speed | Glide | Turn | Fade | Use Case |
|------|-------|-------|------|------|----------|
| Putters | 1-3 | 3-4 | 0 to -2 | 0-1 | Short distance, accuracy |
| Mid-ranges | 4-5 | 4-5 | -3 to 0 | 0-2 | Controlled mid-distance |
| Fairway Drivers | 6-8 | 4-6 | -3 to 0 | 1-2 | Distance with control |
| Distance Drivers | 9-14 | 3-6 | -3 to 1 | 1-5 | Maximum distance |

## Key Research Sources

1. **PDGA Technical Standards**: https://www.pdga.com/rules/technical-standards
2. **Marshall Street Flight Guide**: https://www.marshallstreetdiscgolf.com/flight-guide/
3. **Innova Flight Ratings**: https://www.innovadiscs.com/disc-rating-system/
4. **Disc Golf Review Science**: http://www.discgolfreview.com/resources/articles/understanding-flight.shtml
5. **Physics of Flying Discs** (NASA): https://www.grc.nasa.gov/www/k-12/airplane/rotations.html

## Implementation Recommendations

For an AR app MVP:
1. Start with simple parabolic arcs that include turn/fade offsets
2. Use lookup tables based on the four flight numbers
3. Add wind as a simple vector modifier
4. Allow users to adjust "throw power" (0-100%)
5. Visualize flight path with a dotted line before throwing
6. Use particle effects to show air flow

## Open Source Physics Libraries

- **Cannon.js** (JavaScript): Good for 3D physics simulation
- **Ammo.js** (JavaScript): Bullet physics port, good for rigid body dynamics
- **PhysX** (Unity): Industry standard if using Unity
- **Matter.js** (JavaScript): 2D physics, simpler for basic trajectories
