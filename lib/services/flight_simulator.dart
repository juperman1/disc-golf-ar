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

/// Disc Flight Physics Simulation
/// Based on aerodynamics of spinning discs
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
    windSpeed = windSpeed.clamp(-50.0, 50.0);
    
    // Flight numbers
    final speedRating = disc.speed.toDouble();
    final glideRating = disc.glide.toDouble();
    final turnRating = disc.turn.toDouble(); // Usually 0 to -5
    final fadeRating = disc.fade.toDouble(); // Usually 0 to 5
    
    // PHYSICS CONSTANTS
    const gravity = 9.81;
    const airDensity = 1.225; // kg/m³
    const discMass = 0.175; // kg (typical 175g disc)
    const discArea = 0.055; // m² (approx disc area)
    const timeStep = 0.015; // seconds - smaller = more accurate
    
    // THROW PARAMETERS
    // Initial velocity based on disc speed rating and throw power
    // Speed rating 12 needs ~25 m/s, Speed 5 needs ~18 m/s
    final baseVelocity = 15.0 + (speedRating * 0.9);
    final throwVelocity = baseVelocity * power; // 18-25 m/s
    
    // Release angle - hyzer or anhyzer based on turn/fade balance
    // For a flat throw, slight hyzer for overstable, slight anhyzer for understable
    final releaseAngle = (turnRating + fadeRating) * 1.5; // degrees
    final releaseAngleRad = releaseAngle * pi / 180;
    
    // WIND
    final windRad = windDirection * pi / 180;
    final windV = windSpeed / 3.6; // m/s
    final windX = -cos(windRad) * windV; // headwind (+) / tailwind (-)
    final windY = sin(windRad) * windV; // crosswind
    
    // Initial state
    double x = 0; // forward
    double y = 0; // lateral
    double h = 1.3; // height
    
    // Initial velocities
    double vx = throwVelocity * cos(releaseAngleRad);
    double vy = throwVelocity * sin(releaseAngleRad);
    double vh = throwVelocity * 0.15; // slight upward component
    
    double maxH = h;
    double time = 0;
    const maxTime = 6.0; // max 6 seconds
    
    // Simulation loop
    while (time < maxTime && h >= 0 && vx > 1.0) {
      time += timeStep;
      
      // Current airspeed (relative to wind)
      final vAirX = vx - windX;
      final vAirY = vy - windY;
      final vAirTotal = sqrt(vAirX * vAirX + vAirY * vAirY + vh * vh);
      final vGround = sqrt(vx * vx + vy * vy + vh * vh);
      
      if (vAirTotal < 0.1) break;
      
      // Speed ratio - how much speed remains
      final speedRatio = (vAirTotal / throwVelocity).clamp(0.0, 1.0);
      
      // LIFT
      // Discs generate lift from spin and forward motion
      // Higher glide = better lift at lower speeds
      // Lift coefficient peaks around mid-flight
      final liftCoeff = (glideRating / 7.0) * 0.35 * (1.0 - speedRatio * 0.3);
      final liftForce = 0.5 * airDensity * vAirTotal * vAirTotal * discArea * liftCoeff;
      
      // DRAG
      // Discs have surprisingly low drag (better than spheres due to shape)
      // Drag coefficient increases at very low speeds
      final dragCoeff = 0.08 + (1.0 - speedRatio) * 0.1;
      final dragForce = 0.5 * airDensity * vAirTotal * vAirTotal * discArea * dragCoeff;
      
      // Apply forces
      // Drag opposes motion
      final dragAccel = dragForce / discMass;
      vx -= dragAccel * timeStep * (vx / vGround);
      
      // Gravity and lift
      vh -= gravity * timeStep;
      vh += (liftForce / discMass) * timeStep * 0.4;
      
      // **TURN PHYSICS**
      // Turn happens when disc is understable (negative turn rating)
      // It's caused by aerodynamic torque on the spinning disc
      // Occurs at HIGH speed because understable discs want to turn over
      
      // Turn effectiveness - strongest at 60-80% of max speed
      final turnEffectiveness = turnRating < 0 
          ? exp(-pow(speedRatio - 0.7, 2) / 0.1) * (-turnRating / 5.0) 
          : 0;
      
      // Turn direction - understable discs turn RIGHT for RHBH
      // This is because the trailing edge lifts, creating rightward force
      final turnForce = turnEffectiveness * speedRatio * 15.0;
      vy += turnForce * timeStep;
      
      // **FADE PHYSICS**
      // Fade happens when disc loses speed and becomes overstable
      // Occurs at LOW speed (last 30% of flight)
      // Overstable discs fade LEFT for RHBH
      
      // Fade effectiveness increases as speed drops
      final fadeEffectiveness = fadeRating > 0 > 0
          ? (1.0 - speedRatio).clamp(0.0, 1.0) * (fadeRating / 5.0)
          : 0;
      
      // Fade direction - LEFT for RHBH
      final fadeForce = fadeEffectiveness * 20.0;
      vy -= fadeForce * timeStep;
      
      // Wind lateral effect
      vy += windY * timeStep * 0.5;
      
      // Damping on lateral to prevent unrealistic drift
      vy *= (1.0 - timeStep * 0.1);
      
      // Update positions
      x += vx * timeStep;
      y += vy * timeStep;
      h += vh * timeStep;
      
      if (h > maxH) maxH = h;
      
      // Record point
      if ((time * 100).toInt() % 4 == 0) {
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
    
    // Ensure minimum path
    if (path.isEmpty) {
      path.add(FlightPoint(x: 0, y: 0, height: 1.3, speed: 1.0));
    }
    if (path.length < 2 || h > 0) {
      path.add(FlightPoint(
        x: x,
        y: y,
        height: h.clamp(0.0, 50.0),
        speed: 0,
      ));
    }
    
    final last = path.last;
    return FlightResult(
      path: path,
      totalDistance: last.x.isFinite && last.x > 0 ? last.x : 60.0,
      maxHeight: maxH.isFinite && maxH > 0 ? maxH : 8.0,
      finalLateral: last.y.isFinite ? last.y : 0.0,
    );
  }
}
