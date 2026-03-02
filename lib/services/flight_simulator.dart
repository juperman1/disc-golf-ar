import 'dart:math';
import '../models/disc.dart';

class FlightPoint {
  final double x; // distance in meters (forward from thrower)
  final double y; // lateral position (right positive, left negative) - for visualization
  final double height; // actual height in meters
  final double speed; // current speed percentage (0-1)

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

/// Realistic Disc Golf Flight Simulator
/// 
/// Physics model based on flight numbers:
/// - Speed: Affects initial velocity and max distance potential
/// - Glide: Affects how long disc stays aloft (lift coefficient)
/// - Turn: Affects lateral drift at high speeds (negative = right turn for RHBH)
/// - Fade: Affects lateral drift at low speeds (positive = left fade for RHBH)
class FlightSimulator {
  static FlightResult calculateFlight({
    required Disc disc,
    required double power,
    required double windSpeed,
    required double windDirection,
  }) {
    final List<FlightPoint> path = [];
    
    // Normalize flight numbers
    final speedFactor = disc.speed / 14.0;
    final glideFactor = disc.glide / 7.0;
    final turnFactor = disc.turn / -5.0; // Normalize negative turn
    final fadeFactor = disc.fade / 5.0;
    
    // Physical constants
    const airDensity = 1.225;
    const discMass = 0.175;
    const discArea = 0.038;
    const gravity = 9.81;
    const timeStep = 0.02; // Smaller timestep = more points = smoother curve
    
    // Initial velocity based on power and disc speed
    final initialSpeed = (15.0 + disc.speed * 1.5) * power;
    final initialHeight = 1.5;
    
    // Wind in m/s
    final windRad = windDirection * pi / 180;
    final windSpeedMs = windSpeed / 3.6;
    final windX = cos(windRad) * windSpeedMs;
    final windZ = sin(windRad) * windSpeedMs;
    
    // State variables
    double x = 0, y = initialHeight, z = 0;
    double vx = initialSpeed, vy = initialSpeed * 0.2 * glideFactor, vz = 0;
    double maxH = initialHeight;
    
    bool groundHit = false;
    int iterations = 0;
    
    while (!groundHit && iterations < 3000) {
      iterations++;
      
      // Current speed and speed ratio
      final vTotal = sqrt(vx*vx + vy*vy + vz*vz);
      final speedRatio = vTotal / initialSpeed;
      
      // Relative velocity to air
      final vRelX = vx - windX;
      final vRelZ = vz - windZ;
      final vRelTotal = sqrt(vRelX*vRelX + vy*vy + vRelZ*vRelZ);
      
      // Dynamic pressure
      final dynamicPressure = 0.5 * airDensity * vRelTotal * vRelTotal;
      
      // Aerodynamic coefficients
      final dragCoeff = 0.4 + (1.0 - speedRatio) * 0.3;
      final liftCoeff = glideFactor * (0.5 + 0.5 * cos((1.0 - speedRatio) * pi * 0.5));
      
      // Turn is active at high speed (first 60% of speed)
      final turnEffect = speedRatio > 0.4 ? turnFactor * (speedRatio - 0.4) / 0.6 : 0;
      
      // Fade is active at low speed (below 50% speed)
      final fadeEffect = speedRatio < 0.5 ? fadeFactor * (0.5 - speedRatio) / 0.5 : 0;
      
      // Forces
      final forceDrag = dynamicPressure * discArea * dragCoeff;
      final forceLift = dynamicPressure * discArea * liftCoeff;
      final lateralForce = (turnEffect - fadeEffect) * forceLift * 0.3;
      
      // Accelerations
      final ax = -(forceDrag / discMass) * (vx / vTotal);
      final ay = (forceLift / discMass) - gravity;
      final az = lateralForce / discMass;
      
      // Update
      vx += ax * timeStep;
      vy += ay * timeStep;
      vz += az * timeStep;
      
      x += vx * timeStep;
      y += vy * timeStep;
      z += vz * timeStep;
      
      if (y > maxH) maxH = y;
      if (y <= 0) {
        groundHit = true;
        y = 0;
      }
      
      // Record every iteration for maximum smoothness
      path.add(FlightPoint(
        x: x,
        y: z, // lateral deviation
        height: y,
        speed: speedRatio,
      ));
    }
    
    return FlightResult(
      path: path,
      totalDistance: x,
      maxHeight: maxH,
      finalLateral: z,
    );
  }
}
