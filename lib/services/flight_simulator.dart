import 'dart:math';
import '../models/disc.dart';

class FlightPoint {
  final double x; // distance in meters (forward)
  final double y; // height in meters
  final double z; // lateral position (right positive, left negative)
  final double speed; // current speed (0-1)

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
  final double finalLateral;

  FlightResult({
    required this.path,
    required this.totalDistance,
    required this.maxHeight,
    required this.finalLateral,
  });
}

class FlightSimulator {
  /// Calculate flight path based on disc flight numbers
  /// 
  /// Flight Numbers explained:
  /// - Speed (1-14): Higher = faster, needs more power, flies farther
  /// - Glide (1-7): Higher = stays aloft longer
  /// - Turn (-5 to 1): Negative = turns right during high speed (understable)
  /// - Fade (0-5): Higher = fades left at end (overstable)
  /// 
  /// For RHBH (Right Hand Back Hand):
  /// - Turn < 0: Moves right during high speed
  /// - Fade > 0: Moves left at end
  static FlightResult calculateFlight({
    required Disc disc,
    required double power, // 0.3 to 1.0 (throw power)
    required double windSpeed, // 0-30 km/h
    required double windDirection, // degrees: 0=headwind, 90=from right, 180=tailwind, 270=from left
  }) {
    final List<FlightPoint> path = [];
    
    // Flight numbers
    final speed = disc.speed;
    final glide = disc.glide;
    final turn = disc.turn; // -5 to 1
    final fade = disc.fade; // 0 to 5
    
    // Base distance calculation based on speed and power
    // Speed 14 with 100% power = ~150m
    // Speed 2 with 70% power = ~40m
    final baseDistance = (speed * 10 + glide * 5) * power;
    
    // Wind effect
    // Headwind (0°) = more turn, less distance
    // Tailwind (180°) = less turn, more distance
    // From right (90°) = pushes disc right
    // From left (270°) = pushes disc left
    final windRad = windDirection * pi / 180;
    final headwindComponent = cos(windRad); // -1 to 1 (tailwind positive)
    final crosswindComponent = sin(windRad); // -1 to 1 (from right positive)
    
    // Distance adjustment
    final distance = baseDistance * (1 + headwindComponent * windSpeed / 100);
    
    // Calculate turn and fade effects
    // Turn is most active at high speed (first 30-40% of flight)
    // Fade is most active at low speed (last 20-30% of flight)
    
    final maxTurnDistance = distance * 0.35; // Turn phase
    final fadeStartDistance = distance * 0.6; // Fade starts here
    
    // Step through flight
    const steps = 100;
    double currentX = 0;
    double currentZ = 0;
    double currentY = 0;
    double maxH = 0;
    
    for (int i = 0; i <= steps; i++) {
      final progress = i / steps; // 0.0 to 1.0
      final prevProgress = (i - 1) / steps;
      
      // Current distance along flight path
      currentX = distance * progress;
      
      // Speed decays over flight
      // Higher glide = slower speed decay
      final speedDecay = pow(progress, 1.0 / (glide / 4 + 0.5));
      final currentSpeed = 1.0 - speedDecay; // 1.0 at start, near 0 at end
      
      // Height parabola based on glide
      // Higher glide = flatter arc, stays up longer
      final heightFactor = sin(progress * pi * (0.5 + glide / 14));
      final maxHeight = 15.0 + glide * 2; // meters
      currentY = maxHeight * heightFactor * power;
      if (currentY > maxH) maxH = currentY;
      
      // Lateral movement (turn + fade)
      double lateralMovement = 0;
      
      // Turn phase (first 35% of flight)
      if (currentX < maxTurnDistance) {
        final turnProgress = currentX / maxTurnDistance;
        // Turn value: -5 (max right) to 1 (slight left)
        // Negative turn = moves right (understable)
        final turnEffect = -turn * 3 * turnProgress; // Scale turn effect
        lateralMovement += turnEffect;
      }
      
      // Fade phase (last 40% of flight)
      if (currentX > fadeStartDistance) {
        final fadeProgress = (currentX - fadeStartDistance) / (distance - fadeStartDistance);
        // Fade value: 0 (no fade) to 5 (hard fade left)
        final fadeEffect = -fade * 4 * fadeProgress; // Negative = left
        lateralMovement += fadeEffect;
      }
      
      // Wind effect on lateral movement
      // From right pushes disc left, from left pushes disc right
      lateralMovement += crosswindComponent * windSpeed * (progress * progress) * 0.5;
      
      currentZ = lateralMovement;
      
      path.add(FlightPoint(
        x: currentX,
        y: currentY,
        z: currentZ,
        speed: currentSpeed,
      ));
    }
    
    return FlightResult(
      path: path,
      totalDistance: distance,
      maxHeight: maxH,
      finalLateral: currentZ,
    );
  }
}
