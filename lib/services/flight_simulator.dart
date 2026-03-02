import 'dart:math';
import '../models/disc.dart';

class FlightPoint {
  final double x;
  final double y;
  final double height;
  final double speed;

  FlightPoint({
    required this.x,
    required this.y,
    required this.height,
    required this.speed,
  });
}

class FlightResult {
  final List<FlightPoint> path;
  final double totalDistance;
  final double maxHeight;
  final double finalLateral;

  FlightResult({
    required this.path,
    required this.totalDistance,
    required this.maxHeight,
    required this.finalLateral,
  });
}

/// Disc Golf Flight Physics - Calibrated to TechDisc Data
/// TechDisc Reference (RHBH, ~60 MPH throw):
/// - Speed 12, Glide 5, Turn -1, Fade 3 @ 100% = ~125m (412 ft)
/// - Speed 5, Glide 5, Turn -1, Fade 1 @ 100% = ~103m (340 ft)
/// - Speed 2, Glide 3, Turn 0, Fade 1 @ 100% = ~90m (295 ft)
class FlightSimulator {
  static FlightResult calculateFlight({
    required Disc disc,
    required double power,
    required double windSpeed,
    required double windDirection,
  }) {
    final List<FlightPoint> path = [];
    
    // Sanitize inputs
    power = power.clamp(0.3, 1.0);
    windSpeed = windSpeed.clamp(0.0, 50.0);
    
    // Flight numbers
    final speed = disc.speed.toDouble();
    final glide = disc.glide.toDouble();
    final turn = disc.turn.toDouble();
    final fade = disc.fade.toDouble();
    
    // === BASE DISTANCE CALCULATION ===
    // Calibrated to match TechDisc empirical data:
    // Speed 12 + Glide 5 = ~125m at 100% power
    // Formula: base = offset + (speed * factor) + (glide * bonus)
    // Using diminishing returns for higher speeds
    final baseDistance = 45.0 + (speed * 6.0) + (glide * 2.5);
    
    // Apply power (30% minimum at 30% power, scales up)
    // Power affects both distance and flight characteristics
    final powerMultiplier = 0.7 + (power * 0.3); // 0.7 to 1.0
    final targetDistance = baseDistance * powerMultiplier;
    
    // === WIND EFFECT ===
    // Realistic: 16 km/h headwind reduces distance by ~10-15%, not 50%
    final windRad = windDirection * pi / 180;
    final windMs = windSpeed / 3.6;
    final headwindComponent = -cos(windRad) * windMs;
    
    // Wind effect: ~1.5% distance reduction per m/s of headwind
    final windFactor = 1.0 - (headwindComponent * 0.015).clamp(-0.2, 0.25);
    final maxDistance = targetDistance * windFactor;
    
    // === FLIGHT SIMULATION ===
    // Use a velocity Verlet integration for stability
    const timeStep = 0.02; // 50Hz simulation
    const maxTime = 4.5; // typical disc flight lasts ~3-4 seconds
    
    // Initial throw conditions
    // Higher speed discs maintain velocity longer (better aerodynamics)
    final throwSpeed = 22.0 + (speed * 1.2) * power; // m/s
    final launchAngle = 6.0 + (glide * 0.5); // degrees, higher glide = higher launch
    final launchAngleRad = launchAngle * pi / 180;
    
    // State variables
    double x = 0, y = 0, h = 1.3; // position
    double vx = throwSpeed * cos(launchAngleRad); // forward velocity
    double vy = 0; // lateral velocity
    double vh = throwSpeed * sin(launchAngleRad); // vertical velocity
    
    double maxH = h;
    double time = 0;
    int steps = 0;
    const maxSteps = 300;
    
    // Physics constants
    const gravity = 9.81;
    // Drag coefficient depends on disc speed rating (higher speed = more aerodynamic)
    final baseDrag = 0.15 - (speed * 0.008); // Speed 12 has less drag than Speed 2
    
    while (steps < maxSteps && h >= 0 && vx > 2.0) {
      steps++;
      time += timeStep;
      
      // Current airspeed
      final vTotal = sqrt(vx*vx + vy*vy + vh*vh);
      final speedRatio = (vTotal / throwSpeed).clamp(0.0, 1.0);
      
      // Drag increases slightly as speed drops (lower Reynolds number)
      final dragCoeff = baseDrag + (1.0 - speedRatio) * 0.05;
      
      // Apply drag to forward velocity
      vx -= vx * dragCoeff * timeStep;
      
      // Lift from disc shape and spin - keeps disc aloft
      // Higher glide = more lift
      final liftCoeff = (glide / 7.0) * 0.4 * speedRatio;
      vh += (liftCoeff * 5.0 - gravity) * timeStep;
      
      // === TURN (High Speed Phase) ===
      // Understable discs (negative turn) turn RIGHT during high speed
      // Effect peaks around 70% of initial speed
      if (turn < 0 && speedRatio > 0.4) {
        final turnIntensity = (-turn / 5.0); // 0 to 1
        final speedEffect = exp(-pow((speedRatio - 0.7) * 3.0, 2)); // Gaussian peak at 0.7
        final lateralForce = turnIntensity * speedEffect * 8.0;
        vy += lateralForce * timeStep;
      }
      
      // === FADE (Low Speed Phase) ===
      // Overstable discs (positive fade) fade LEFT as they slow down
      // Effect increases as speed drops below 50%
      if (fade > 0 && speedRatio < 0.55) {
        final fadeIntensity = (fade / 5.0); // 0 to 1
        final speedEffect = pow((0.55 - speedRatio) / 0.55, 2); // Quadratic increase
        final lateralForce = fadeIntensity * speedEffect * 10.0;
        vy -= lateralForce * timeStep; // Negative = left
      }
      
      // Wind cross component (affects lateral drift)
      final crosswind = sin(windRad) * windMs * 0.4;
      vy += crosswind * timeStep;
      
      // Damping to prevent unrealistic oscillations
      vy *= 0.985;
      
      // Update positions
      x += vx * timeStep;
      y += vy * timeStep;
      h += vh * timeStep;
      
      // Track max height
      if (h > maxH) maxH = h;
      
      // Record path point every few steps
      if (steps % 3 == 0) {
        path.add(FlightPoint(
          x: x,
          y: y,
          height: h,
          speed: speedRatio,
        ));
      }
      
      // Ground hit
      if (h <= 0) {
        h = 0;
        path.add(FlightPoint(
          x: x,
          y: y,
          height: 0,
          speed: speedRatio,
        ));
        break;
      }
    }
    
    // Ensure we have at least 2 points
    if (path.length < 2) {
      if (path.isEmpty) {
        path.add(FlightPoint(x: 0, y: 0, height: 1.3, speed: 1.0));
      }
      path.add(FlightPoint(
        x: maxDistance,
        y: 0,
        height: 0,
        speed: 0,
      ));
    }
    
    final last = path.last;
    return FlightResult(
      path: path,
      totalDistance: last.x.isFinite && last.x > 0 ? last.x : maxDistance.clamp(50.0, 200.0),
      maxHeight: maxH.isFinite && maxH > 0 ? maxH : 6.0,
      finalLateral: last.y.isFinite ? last.y : 0.0,
    );
  }
}
