import 'dart:math';
import '../models/disc.dart';

class FlightPoint {
  final double x; // forward distance (meters)
  final double y; // lateral deviation (meters, positive = right, negative = left)
  final double height; // height (meters)
  final double speed; // current airspeed ratio (0-1)

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

/// Disc Golf Flight Physics - Based on TechDisc Empirical Data
/// 
/// TechDisc Reference Data (RHBH, Flat Throw, ~60 MPH):
/// - Speed 12 (Destroyer): 125-135m (412-434 ft)
/// - Speed 5 (Buzzz-type): 103m (340 ft)
/// - Speed 2 (Putter): 90m (295 ft)
///
/// Flight Physics:
/// - Turn: Occurs at HIGH speed, moves disc RIGHT for understable discs (RHBH)
/// - Fade: Occurs at LOW speed, moves disc LEFT for overstable discs (RHBH)
/// - The result is an S-curve or graceful arc
class FlightSimulator {
  static FlightResult calculateFlight({
    required Disc disc,
    required double power, // 0.3 to 1.0 (throw power percentage)
    required double windSpeed, // km/h
    required double windDirection, // degrees: 0=headwind, 90=from right, etc.
  }) {
    final List<FlightPoint> path = [];
    
    // Validate inputs
    power = power.clamp(0.3, 1.0);
    windSpeed = windSpeed.clamp(0.0, 50.0);
    
    // Flight numbers
    final speed = disc.speed.toDouble();
    final glide = disc.glide.toDouble();
    final turn = disc.turn.toDouble(); // 0 to -5 (more negative = more turn)
    final fade = disc.fade.toDouble(); // 0 to 5
    
    // === DISTANCE CALCULATION (based on TechDisc data) ===
    // Base distance formula derived from empirical data:
    // Speed 12 @ 100% = ~130m, Speed 5 @ 100% = ~105m, Speed 2 @ 100% = ~90m
    final baseDistance = 50.0 + speed * 6.5 + glide * 3.0;
    final maxDistance = baseDistance * power;
    
    // Wind effect on distance
    // Headwind reduces distance, tailwind increases
    final windRad = windDirection * pi / 180;
    final windMs = windSpeed / 3.6;
    final headwindComponent = -cos(windRad) * windMs; // Positive = headwind
    
    // Wind reduces/increases distance by ~1m per km/h
    final distance = maxDistance * (1.0 - headwindComponent * 0.015);
    
    // === FLIGHT SIMULATION ===
    const timeStep = 0.03;
    const maxTime = 5.0; // seconds - typical disc flight time
    
    // Initial throw velocity (affected by power and disc speed)
    // Higher speed discs need more arm speed to work
    final throwVelocity = 20.0 + power * 15.0; // 20-35 m/s
    
    // State variables
    double x = 0; // Forward position
    double y = 0; // Lateral position
    double h = 1.3; // Height
    
    double vx = throwVelocity; // Forward velocity
    double vy = 0; // Lateral velocity
    double vh = 3.0 + glide * 0.3; // Initial upward velocity
    
    double maxH = h;
    double currentTime = 0;
    
    // Flight phases
    while (currentTime < maxTime && h >= 0) {
      currentTime += timeStep;
      
      // Current speed ratio (0 to 1)
      final currentSpeed = sqrt(vx * vx + vy * vy + vh * vh);
      final speedRatio = (currentSpeed / throwVelocity).clamp(0.0, 1.0);
      
      // Drag - slows down forward motion
      // Higher speed = more drag
      final drag = speedRatio * 0.4;
      vx *= (1.0 - drag * timeStep);
      
      // Lift from glide - keeps disc in air
      // As speed drops, lift decreases
      final lift = (glide / 7.0) * speedRatio * 0.6;
      vh -= 9.81 * timeStep; // Gravity
      vh += lift * 4.0 * timeStep; // Counteract gravity
      
      // === TURN (High Speed Phase) ===
      // Turn moves disc RIGHT for understable discs (RHBH)
      // Effect is strongest at 70-90% of initial speed
      // Turn value: 0 to -5 (negative = understable = turn right)
      if (turn < 0 && speedRatio > 0.3) {
        // Turn effectiveness peaks around 70% speed
        final turnFactor = exp(-pow(speedRatio - 0.7, 2) / 0.1);
        final turnAmount = (-turn / 5.0) * turnFactor * vx * 0.08;
        vy += turnAmount * timeStep;
      }
      
      // === FADE (Low Speed Phase) ===
      // Fade moves disc LEFT for overstable discs (RHBH)
      // Effect increases as speed drops below 40%
      if (fade > 0 && speedRatio < 0.5) {
        // Fade effect increases as speed drops
        final fadeFactor = (0.5 - speedRatio).clamp(0.0, 0.5) / 0.5;
        final fadeAmount = (fade / 5.0) * fadeFactor * vx * 0.1;
        vy -= fadeAmount * timeStep; // Minus = left
      }
      
      // Wind lateral effect
      final crosswind = sin(windRad) * windMs;
      vy += crosswind * timeStep * 0.3;
      
      // Damping to prevent unrealistic drift
      vy *= 0.98;
      
      // Update positions
      x += vx * timeStep;
      y += vy * timeStep;
      h += vh * timeStep;
      
      // Track max height
      if (h > maxH) maxH = h;
      
      // Record path point
      if ((currentTime * 100).toInt() % 4 == 0) {
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
      
      // Stop if speed too low
      if (speedRatio < 0.1) break;
    }
    
    // Ensure path has at least 2 points
    if (path.length < 2) {
      path.add(FlightPoint(x: distance, y: 0, height: 0, speed: 0));
    }
    
    final last = path.last;
    return FlightResult(
      path: path,
      totalDistance: last.x.isFinite && last.x > 0 ? last.x : distance,
      maxHeight: maxH.isFinite && maxH > 0 ? maxH : 8.0,
      finalLateral: last.y.isFinite ? last.y : 0.0,
    );
  }
}
