import 'dart:math';
import '../models/disc.dart';

class FlightPoint {
  final double x; // distance in meters
  final double y; // height in meters
  final double z; // lateral position (right positive)
  final double speed; // current speed

  FlightPoint({
    required this.x,
    required this.y,
    required this.z,
    required this.speed,
  });
}

class FlightResult {
  final List<FlightPoint> path;
  final double totalDistance;
  final double maxHeight;
  final int flightTimeMs;

  FlightResult({
    required this.path,
    required this.totalDistance,
    required this.maxHeight,
    required this.flightTimeMs,
  });
}

class FlightSimulator {
  static FlightResult calculateFlight({
    required Disc disc,
    required double power, // 0.0 to 1.0
    required double windSpeed, // km/h
    required double windDirection, // degrees: 0=headwind, 90=from right, 180=tailwind, 270=from left
  }) {
    final List<FlightPoint> path = [];
    
    // Convert wind direction to radians
    final windRad = windDirection * pi / 180;
    
    // Base throw velocity based on power and disc speed
    double baseVelocity = 15.0 + (power * 15.0); // 15-30 m/s
    if (disc.speed <= 5) baseVelocity *= 0.85; // Putters slower
    else if (disc.speed <= 8) baseVelocity *= 0.95; // Fairways slightly slower
    
    // Wind effect on effective speed
    double windHeadwind = windSpeed * cos(windRad) / 3.6; // Convert to m/s
    double windCross = windSpeed * sin(windRad) / 3.6; // Crosswind component
    
    // Initial conditions
    double velocity = baseVelocity - windHeadwind * 0.5;
    double x = 0; // forward distance
    double y = 1.5; // height (release height)
    double z = 0; // lateral position
    double maxHeight = y;
    
    // Turn and fade calculations
    double turnAmount = disc.turn.abs() * 0.8 + (windCross * 0.3);
    double fadeAmount = disc.fade * 0.6 + (windCross * 0.2);
    
    // Simulate 100 time steps
    int steps = 100;
    double dt = 0.03; // 30ms per step
    
    for (int i = 0; i < steps; i++) {
      double t = i / steps; // 0.0 to 1.0
      
      // Speed decay
      velocity *= 0.985;
      
      // Forward movement
      x += velocity * cos(t * 0.1) * dt;
      
      // Height (parabolic arc based on glide)
      double glideFactor = disc.glide / 5.0;
      y = 1.5 + (10.0 * glideFactor * sin(t * pi) * (velocity / 30.0));
      if (y < 0) y = 0; // Ground level
      if (y > maxHeight) maxHeight = y;
      
      // Lateral movement (turn then fade)
      if (t < 0.5) {
        // Turn phase - understable discs turn right
        double turnEffect = disc.turn < 0 ? -turnAmount * sin(t * pi * 2) : 0;
        z += turnEffect * dt + (windCross * 0.1 * dt);
      } else {
        // Fade phase - all discs fade left at end
        double fadeEffect = fadeAmount * sin((t - 0.5) * pi * 2);
        z -= fadeEffect * dt + (windCross * 0.05 * dt);
      }
      
      // Add point to path
      path.add(FlightPoint(
        x: x,
        y: y,
        z: z,
        speed: velocity,
      ));
      
      // Stop if velocity too low
      if (velocity < 3.0) break;
    }
    
    return FlightResult(
      path: path,
      totalDistance: x,
      maxHeight: maxHeight,
      flightTimeMs: (steps * dt * 1000).round(),
    );
  }
  
  static String formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }
  
  static String formatTime(int ms) {
    double seconds = ms / 1000.0;
    return '${seconds.toStringAsFixed(1)} s';
  }
}
