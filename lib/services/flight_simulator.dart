import 'dart:math';
import '../models/disc.dart';

class FlightPoint {
  final double x; // forward distance
  final double y; // lateral deviation
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

class FlightSimulator {
  static FlightResult calculateFlight({
    required Disc disc,
    required double power,
    required double windSpeed,
    required double windDirection,
  }) {
    final List<FlightPoint> path = [];
    
    // Validate inputs
    power = power.clamp(0.3, 1.0);
    windSpeed = windSpeed.clamp(0.0, 50.0);
    
    // Flight characteristics
    final speed = disc.speed.toDouble();
    final glide = disc.glide.toDouble();
    final turn = disc.turn.toDouble();
    final fade = disc.fade.toDouble();
    
    // Physics constants
    const gravity = 9.81;
    const airDensity = 1.225;
    const timeStep = 0.05;
    const maxTime = 10.0; // Max 10 seconds flight time
    
    // Initial conditions - based on disc speed and throw power
    // Higher speed discs = higher initial velocity
    final initialVelocity = 15.0 + (speed * 2.0) * power;
    
    // Throw angle - based on power (higher power = lower angle for distance)
    final throwAngle = 8.0 + (1.0 - power) * 5.0; // 8-13 degrees
    final throwAngleRad = throwAngle * pi / 180;
    
    // Wind components
    final windRad = windDirection * pi / 180;
    final windSpeedMs = windSpeed / 3.6;
    final headwind = cos(windRad) * windSpeedMs;
    final crosswind = sin(windRad) * windSpeedMs;
    
    // Initial state
    double x = 0; // forward
    double y = 1.5; // lateral
    double h = 1.2; // height (throw height)
    
    double vx = initialVelocity * cos(throwAngleRad);
    double vy = 0; // initially straight
    double vh = initialVelocity * sin(throwAngleRad);
    
    double maxH = h;
    double totalTime = 0;
    
    // Flight simulation
    while (totalTime < maxTime && h >= 0) {
      totalTime += timeStep;
      
      // Current forward speed relative to air
      final vForward = vx - headwind;
      final vTotal = sqrt(vForward * vForward + vh * vh + vy * vy);
      
      // Prevent division by zero
      if (vTotal < 0.1) break;
      
      // Speed ratio (how much speed left vs initial)
      final speedRatio = (vTotal / initialVelocity).clamp(0.0, 1.0);
      
      // Drag force reduces forward velocity
      // Higher speed = more drag
      final dragCoeff = 0.5 + (1.0 - speedRatio) * 0.2;
      final dragForce = 0.5 * airDensity * vTotal * vTotal * 0.015 * dragCoeff;
      final dragAccel = dragForce / 0.175; // disc mass ~175g
      
      vx -= dragAccel * timeStep * (vx / vTotal);
      
      // Lift keeps disc in air - based on glide
      // Higher glide = more lift at lower speeds
      final liftCoeff = glide / 7.0 * (0.3 + speedRatio * 0.7);
      final liftForce = 0.5 * airDensity * vTotal * vTotal * 0.015 * liftCoeff;
      final liftAccel = liftForce / 0.175;
      
      // Gravity
      vh -= gravity * timeStep;
      vh += liftAccel * timeStep * 0.3; // Lift counteracts gravity
      
      // Lateral movement (Turn and Fade)
      // Turn: happens at high speed, moves disc right (for RHBH with negative turn)
      // Fade: happens at low speed, moves disc left
      
      double lateralForce = 0;
      
      // Turn phase (first ~50% of flight, when speedRatio > 0.5)
      if (speedRatio > 0.4) {
        // Turn effect: negative turn = understable = moves right
        final turnEffect = turn < 0 ? turn * 2.0 : 0;
        lateralForce += turnEffect * vTotal * 0.1;
      }
      
      // Fade phase (last ~40% of flight, when speedRatio < 0.5)
      if (speedRatio < 0.5) {
        // Fade effect: positive fade = overstable = moves left
        final fadeEffect = fade > 0 ? -fade * 2.5 : 0;
        lateralForce += fadeEffect * vTotal * 0.1;
      }
      
      // Wind effect on lateral
      lateralForce += crosswind * 0.5;
      
      vy += lateralForce * timeStep;
      
      // Update positions
      x += vx * timeStep;
      y += vy * timeStep;
      h += vh * timeStep;
      
      // Track max height
      if (h > maxH) maxH = h;
      
      // Record point
      if (totalTime % 0.1 < timeStep) {
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
    
    // Ensure we have at least one point
    if (path.isEmpty) {
      path.add(FlightPoint(x: 0, y: 0, height: 0, speed: 0));
    }
    
    return FlightResult(
      path: path,
      totalDistance: x.isFinite ? x : 0,
      maxHeight: maxH.isFinite ? maxH : 0,
      finalLateral: y.isFinite ? y : 0,
    );
  }
}
