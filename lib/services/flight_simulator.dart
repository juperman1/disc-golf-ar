import 'dart:math';
import '../models/disc.dart';

class FlightPoint {
  final double x; // distance in meters (forward from thrower)
  final double y; // height in meters
  final double z; // lateral position (right positive, left negative)
  final double speed; // current speed percentage (0-1)
  final double height; // current height

  FlightPoint({
    required this.x,
    required this.y,
    required this.z,
    required this.speed,
    required this.height,
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

/// Realistic Disc Golf Flight Simulator
/// 
/// Physics model based on flight numbers:
/// - Speed: Affects initial velocity and max distance potential
/// - Glide: Affects how long disc stays aloft (lift coefficient)
/// - Turn: Affects lateral drift at high speeds (negative = right turn for RHBH)
/// - Fade: Affects lateral drift at low speeds (positive = left fade for RHBH)
/// 
/// Flight phases:
/// 1. High-speed turn (first 30-40% of flight)
/// 2. Glide phase (middle 30-40% of flight)
/// 3. Low-speed fade (last 20-30% of flight)
class FlightSimulator {
  static FlightResult calculateFlight({
    required Disc disc,
    required double power, // 0.3 to 1.0 (throw power percentage)
    required double windSpeed, // 0-30 km/h
    required double windDirection, // degrees: 0=headwind, 90=from right, 180=tailwind, 270=from left
  }) {
    final List<FlightPoint> path = [];
    
    // Flight numbers (1-14 scale, but normalized to 0-1)
    final speed = disc.speed / 14.0; // 0.07 to 1.0
    final glide = disc.glide / 7.0; // 0.14 to 1.0
    final turn = disc.turn / -5.0; // -0.2 to 0.0 (negative values = turn right)
    final fade = disc.fade / 5.0; // 0.0 to 1.0
    
    // Physical parameters
    const timeStep = 0.05; // seconds
    const airDensity = 1.225; // kg/m³ at sea level
    const discMass = 0.175; // kg (standard disc weight)
    const discArea = 0.038; // m² (approximate disc cross-section)
    const gravity = 9.81; // m/s²
    
    // Initial conditions based on power and speed
    final initialSpeed = 20.0 + (speed * 15.0) * power; // 20-35 m/s depending on disc and power
    final initialHeight = 1.5; // meters (throw height)
    
    // Wind components
    final windRad = windDirection * pi / 180;
    final windSpeedMs = windSpeed / 3.6; // convert km/h to m/s
    final windX = cos(windRad) * windSpeedMs; // headwind/tailwind component
    final windZ = sin(windRad) * windSpeedMs; // crosswind component
    
    // Current state
    double x = 0; // forward distance
    double y = initialHeight; // height
    double z = 0; // lateral position
    double vx = initialSpeed; // forward velocity
    double vy = 0.3 * initialSpeed * glide; // initial upward velocity based on glide
    double vz = 0; // lateral velocity
    double currentSpeed = initialSpeed;
    double maxH = initialHeight;
    
    // Simulation loop
    bool groundHit = false;
    int iterations = 0;
    const maxIterations = 2000; // prevent infinite loop
    
    while (!groundHit && iterations < maxIterations) {
      iterations++;
      
      // Relative velocity (disc velocity - wind velocity)
      final vRelX = vx - windX;
      final vRelZ = vz - windZ;
      final vRel = sqrt(vRelX * vRelX + vy * vy + vRelZ * vRelZ);
      
      // Speed ratio (current vs initial)
      final speedRatio = vRel / initialSpeed;
      
      // Aerodynamic coefficients based on flight numbers and speed ratio
      // Turn and fade are most effective at different speed ratios
      
      // Drag coefficient increases as speed decreases
      final dragCoeff = 0.5 + (1.0 - speedRatio) * 0.3;
      
      // Lift coefficient based on glide and angle of attack
      // Higher glide = more lift at lower speeds
      final liftCoeff = glide * (0.8 + 0.4 * sin(speedRatio * pi));
      
      // Turn moment (lateral force at high speed)
      // Understable discs (negative turn) turn right at high speed
      // Effect is strongest at high speed, diminishes as speed drops
      final turnEffect = turn * (speedRatio > 0.3 ? (speedRatio - 0.3) / 0.7 : 0);
      
      // Fade moment (lateral force at low speed)
      // Overstable discs (positive fade) fade left at low speed
      // Effect increases as speed drops
      final fadeEffect = fade * (speedRatio < 0.4 ? (0.4 - speedRatio) / 0.4 : 0);
      
      // Calculate forces
      final dynamicPressure = 0.5 * airDensity * vRel * vRel;
      final forceDrag = dynamicPressure * discArea * dragCoeff;
      final forceLift = dynamicPressure * discArea * liftCoeff;
      
      // Lateral force from turn and fade
      // For RHBH: negative turn = right turn, positive fade = left fade
      final lateralForce = (turnEffect + fadeEffect) * forceLift * 0.5;
      
      // Accelerations
      final ax = -(forceDrag / discMass) * (vRelX / vRel);
      final ay = (forceLift / discMass) - gravity;
      final az = lateralForce / discMass * (turn < 0 ? -1 : 1);
      
      // Update velocities
      vx += ax * timeStep;
      vy += ay * timeStep;
      vz += az * timeStep;
      
      // Update positions
      x += vx * timeStep;
      y += vy * timeStep;
      z += vz * timeStep;
      
      // Track max height
      if (y > maxH) maxH = y;
      
      // Check ground hit
      if (y <= 0) {
        groundHit = true;
        y = 0;
      }
      
      // Record point every few iterations for smooth curve
      if (iterations % 5 == 0 || groundHit) {
        path.add(FlightPoint(
          x: x,
          y: z, // lateral becomes Y in the visualization plane
          z: z, // keep original for calculation
          speed: speedRatio,
          height: y,
        ));
      }
    }
    
    return FlightResult(
      path: path,
      totalDistance: x,
      maxHeight: maxH,
      finalLateral: z,
    );
  }
}
