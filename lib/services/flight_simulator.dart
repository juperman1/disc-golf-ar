import 'dart:math';
import '../models/disc.dart';

class FlightPoint {
  final double x; // forward distance in meters
  final double y; // lateral deviation in meters
  final double height; // height in meters
  final double speed; // current airspeed percentage (0-1)

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

/// Realistic Disc Flight Simulation based on PDGA physics
/// 
/// Flight Numbers Guide (for RHBH - Right Hand Back Hand):
/// - Speed: 1-14, higher = requires more arm speed, flies farther
/// - Glide: 1-7, higher = stays in air longer  
/// - Turn: 0 to -5, more negative = more understable, turns RIGHT during high speed
/// - Fade: 0-5, higher = more overstable, fades LEFT at end of flight
///
/// Typical Distances (RHBH, flat throw, no wind):
/// - Speed 12: 100-130m (Destroyer type)
/// - Speed 5: 60-80m (Buzzz type)
/// - Speed 2: 30-50m (Putter)
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
    windSpeed = windSpeed.clamp(0.0, 40.0);
    
    // Flight numbers
    final speed = disc.speed.toDouble();
    final glide = disc.glide.toDouble();
    final turn = disc.turn.toDouble();
    final fade = disc.fade.toDouble();
    
    // Base distances based on disc speed and power
    // These are realistic max distances for RHBH
    final baseDistances = {
      1: 30.0, 2: 40.0, 3: 50.0, 4: 60.0, 5: 70.0,
      6: 80.0, 7: 90.0, 8: 95.0, 9: 105.0, 10: 115.0,
      11: 120.0, 12: 130.0, 13: 140.0, 14: 150.0,
    };
    
    // Get base distance for this disc's speed
    final baseDist = baseDistances[speed.toInt().clamp(1, 14)] ?? 80.0;
    
    // Calculate max distance with power and glide
    // Glide adds distance (up to 20% at max glide)
    final glideBonus = glide / 7.0 * 0.25;
    final maxDistance = baseDist * power * (1.0 + glideBonus);
    
    // Flight characteristics
    const timeStep = 0.02; // seconds
    const grav = 9.81;
    
    // Wind components in m/s
    final windRad = windDirection * pi / 180;
    final windMs = windSpeed / 3.6;
    final headwind = -cos(windRad) * windMs; // Positive = headwind
    final crosswind = sin(windRad) * windMs; // Positive = from right
    
    // Initial conditions
    double x = 0; // forward
    double y = 0; // lateral  
    double h = 1.3; // height (throw height)
    
    // Velocity components
    // Initial forward velocity based on power and disc speed
    double vx = (15.0 + speed * 1.5) * power; // 15-36 m/s
    double vy = 0; // initially straight forward
    double vh = 5.0 + glide * 0.5; // initial upward (6-8.5 m/s based on glide)
    
    double maxH = h;
    double totalTime = 0;
    const maxTime = 8.0; // max 8 seconds flight
    
    while (totalTime < maxTime && h >= 0) {
      totalTime += timeStep;
      
      // Current speed relative to ground
      final vGround = sqrt(vx * vx + vh * vh);
      
      // Speed relative to air (accounting for wind)
      final vxAir = vx - headwind;
      final vAir = sqrt(vxAir * vxAir + vh * vh + vy * vy);
      
      // Prevent division by zero
      if (vAir < 0.1 || vx < 0.1) break;
      
      // Speed ratio (0.0 to 1.0)
      final initialV = (15.0 + speed * 1.5);
      final speedRatio = (vAir / initialV).clamp(0.0, 1.0);
      
      // Drag slows down forward motion
      // Higher speed = more drag
      final dragFactor = 0.3 + speed * 0.02; // speed 12 has more drag
      vx -= dragFactor * 0.5 * speedRatio * timeStep;
      
      // Lift keeps disc in air
      // Glide determines how long disc stays up
      // As speed drops, lift decreases
      final liftFactor = (glide / 7.0) * 0.8 * speedRatio;
      vh -= grav * timeStep;
      vh += liftFactor * timeStep * 2.0;
      
      // **TURN** - happens at HIGH speed (first 40% of flight)
      // For RHBH: negative turn = understable = moves RIGHT (positive y)
      // Effect is strongest at high speed, fades as speed drops
      final turnEffect = turn < 0 && speedRatio > 0.5
          ? -turn * 3.0 * ((speedRatio - 0.5) / 0.5) * vx * timeStep * 0.15
          : 0.0;
          
      // **FADE** - happens at LOW speed (last 40% of flight)
      // For RHBH: positive fade = overstable = moves LEFT (negative y)
      // Effect increases as speed drops
      final fadeEffect = fade > 0 && speedRatio < 0.5
          ? -fade * 2.5 * ((0.5 - speedRatio) / 0.5) * vx * timeStep * 0.15
          : 0.0;
      
      // Wind effect on lateral
      // Crosswind from right pushes disc left, from left pushes right
      final windEffect = crosswind * timeStep * 0.3;
      
      // Update lateral velocity
      vy += turnEffect + fadeEffect + windEffect;
      
      // Apply some damping to lateral drift
      vy *= 0.98;
      
      // Update positions
      x += vx * timeStep;
      y += vy * timeStep;
      h += vh * timeStep;
      
      // Track max height
      if (h > maxH) maxH = h;
      
      // Record point every 0.1 seconds for smooth curve
      if ((totalTime * 100).toInt() % 5 == 0) {
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
    
    // Ensure we have at least start and end
    if (path.isEmpty) {
      path.add(FlightPoint(x: 0, y: 0, height: 1.3, speed: 1.0));
      path.add(FlightPoint(x: maxDistance, y: 0, height: 0, speed: 0));
    }
    
    return FlightResult(
      path: path,
      totalDistance: path.last.x.isFinite && path.last.x > 0 
          ? path.last.x 
          : maxDistance,
      maxHeight: maxH.isFinite && maxH > 0 
          ? maxH 
          : 8.0,
      finalLateral: path.last.y.isFinite 
          ? path.last.y 
          : 0.0,
    );
  }
}
