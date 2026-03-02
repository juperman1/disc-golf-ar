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

/// Disc Flight Physics - Calibrated
class FlightSimulator {
  static FlightResult calculateFlight({
    required Disc disc,
    required double power,
    required double windSpeed,
    required double windDirection,
  }) {
    final List<FlightPoint> path = [];
    
    power = power.clamp(0.3, 1.0);
    windSpeed = windSpeed.clamp(0.0, 50.0);
    
    final speed = disc.speed.toDouble();
    final glide = disc.glide.toDouble();
    final turn = disc.turn.toDouble();
    final fade = disc.fade.toDouble();
    
    // Base distance (no wind)
    final baseDistance = 45.0 + (speed * 6.0) + (glide * 2.5);
    final powerDistance = baseDistance * (0.7 + power * 0.3);
    
    // Wind effect - LESS aggressive
    // 30 km/h headwind = ~20-25% reduction (not 50%)
    // 16 km/h headwind = ~10-12% reduction
    final windRad = windDirection * pi / 180;
    final windMs = windSpeed / 3.6;
    final headwind = -cos(windRad) * windMs;
    
    // Wind factor: 0.008 per m/s (less than before 0.015)
    // Max reduction: 30% even at 50 km/h
    final windEffect = (headwind * 0.008).clamp(-0.15, 0.30);
    final maxDistance = powerDistance * (1.0 - windEffect);
    
    // Flight simulation
    const timeStep = 0.02;
    const maxTime = 4.5;
    
    final throwSpeed = 20.0 + speed * 1.2;
    final launchAngle = 0.12; // ~7 degrees
    
    double x = 0, y = 0, h = 1.3;
    double vx = throwSpeed * cos(launchAngle);
    double vy = 0;
    double vh = throwSpeed * sin(launchAngle) + glide * 0.3;
    
    double maxH = h;
    double time = 0;
    int step = 0;
    const maxSteps = 400;
    
    const gravity = 9.81;
    final dragBase = max(0.08, 0.18 - speed * 0.008);
    
    while (step < maxSteps && h >= 0 && vx > 1.5) {
      step++;
      time += timeStep;
      
      final vTotal = sqrt(vx*vx + vy*vy + vh*vh);
      final speedRatio = (vTotal / throwSpeed).clamp(0.0, 1.0);
      
      // Drag
      final drag = dragBase + (1.0 - speedRatio) * 0.03;
      vx -= vx * drag * timeStep;
      
      // Lift and gravity
      final lift = (glide / 7.0) * 0.35 * speedRatio;
      vh -= gravity * timeStep;
      vh += lift * 4.5 * timeStep;
      
      // Turn (high speed)
      if (turn < 0 && speedRatio > 0.35) {
        final turnInt = (-turn / 5.0);
        final speedEff = exp(-pow((speedRatio - 0.7) * 2.5, 2));
        vy += turnInt * speedEff * 6.0 * timeStep;
      }
      
      // Fade (low speed)
      if (fade > 0 && speedRatio < 0.5) {
        final fadeInt = (fade / 5.0);
        final speedEff = pow((0.5 - speedRatio) / 0.5, 1.5);
        vy -= fadeInt * speedEff * 8.0 * timeStep;
      }
      
      // Wind cross
      vy += sin(windRad) * windMs * 0.15 * timeStep;
      vy *= 0.99;
      
      x += vx * timeStep;
      y += vy * timeStep;
      h += vh * timeStep;
      
      if (h > maxH) maxH = h;
      
      if (step % 3 == 0) {
        path.add(FlightPoint(x: x, y: y, height: h, speed: speedRatio));
      }
      
      if (h <= 0) break;
    }
    
    if (path.isEmpty) {
      path.add(FlightPoint(x: 0, y: 0, height: 1.3, speed: 1.0));
    }
    if (path.length < 2) {
      path.add(FlightPoint(x: maxDistance, y: 0, height: 0, speed: 0));
    }
    
    return FlightResult(
      path: path,
      totalDistance: path.last.x,
      maxHeight: maxH,
      finalLateral: path.last.y,
    );
  }
}
