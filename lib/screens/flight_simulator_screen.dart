import 'package:flutter/material.dart';
import '../models/disc.dart';
import '../services/flight_simulator.dart';

class FlightSimulatorScreen extends StatefulWidget {
  final Disc disc;

  const FlightSimulatorScreen({super.key, required this.disc});

  @override
  State<FlightSimulatorScreen> createState() => _FlightSimulatorScreenState();
}

class _FlightSimulatorScreenState extends State<FlightSimulatorScreen> {
  double windSpeed = 0;
  String windDirection = 'front';
  double throwPower = 70;
  FlightResult? flightResult;

  double _getWindDirectionDegrees(String direction) {
    switch (direction) {
      case 'front':
        return 0; // headwind
      case 'right':
        return 90; // from right
      case 'back':
        return 180; // tailwind
      case 'left':
        return 270; // from left
      default:
        return 0;
    }
  }

  void _simulateFlight() {
    final result = FlightSimulator.calculateFlight(
      disc: widget.disc,
      power: throwPower / 100,
      windSpeed: windSpeed,
      windDirection: _getWindDirectionDegrees(windDirection),
    );
    setState(() {
      flightResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.disc.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Disc Info Card
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(widget.disc.name, style: Theme.of(context).textTheme.headlineSmall),
                  Text('${widget.disc.brand} | ${widget.disc.flightNumbers}'),
                  const SizedBox(height: 4),
                  Text(
                    _getDiscDescription(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildWindControls(),
                const SizedBox(height: 8),
                _buildPowerSlider(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _simulateFlight,
                    child: const Text('Simulate Flight'),
                  ),
                ),
              ],
            ),
          ),
          
          // Flight Visualization
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FlightVisualization(
                flightResult: flightResult,
                disc: widget.disc,
              ),
            ),
          ),
          
          // Stats with explanations
          if (flightResult != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat('Distance', '${flightResult!.totalDistance.toStringAsFixed(1)}m', 'How far the disc flies'),
                  _buildStat('Max Height', '${flightResult!.maxHeight.toStringAsFixed(1)}m', 'Highest point in flight'),
                  _buildStat('Lateral', '${flightResult!.finalLateral.abs().toStringAsFixed(1)}m ${_getLateralDirection()}', 'Left/right from target'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getLateralDirection() {
    if (flightResult == null) return '';
    return flightResult!.finalLateral > 0 ? '→' : '←';
  }

  String _getDiscDescription() {
    final s = widget.disc.speed;
    final t = widget.disc.turn;
    final f = widget.disc.fade;
    
    if (t < -2) return 'Very Understable - great for beginners, hyzer flips';
    if (t < 0 && f > 3) return 'Moderately Stable - versatile, straight flight';
    if (f > 3) return 'Overstable - reliable fade, windy conditions';
    if (s >= 12) return 'Distance Driver - maximum distance potential';
    if (s >= 9) return 'Fairway Driver - control and distance';
    if (s >= 6) return 'Midrange - accuracy and control';
    return 'Putter - precision approach shots';
  }

  Widget _buildWindControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wind: ${windSpeed.toStringAsFixed(0)} km/h', style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: windSpeed,
          min: 0,
          max: 30,
          divisions: 30,
          label: windSpeed.toStringAsFixed(0),
          onChanged: (value) => setState(() => windSpeed = value),
        ),
        Text('Direction:', style: Theme.of(context).textTheme.bodySmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDirectionButton('left', '← Left'),
            _buildDirectionButton('front', '↑ Front'),
            _buildDirectionButton('back', '↓ Back'),
            _buildDirectionButton('right', '→ Right'),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionButton(String direction, String label) {
    return ElevatedButton(
      onPressed: () => setState(() => windDirection = direction),
      style: ElevatedButton.styleFrom(
        backgroundColor: windDirection == direction ? Colors.blue : Colors.grey.shade300,
        foregroundColor: windDirection == direction ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }

  Widget _buildPowerSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Throw Power: ${throwPower.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: throwPower,
          min: 30,
          max: 100,
          divisions: 70,
          label: throwPower.toStringAsFixed(0),
          onChanged: (value) => setState(() => throwPower = value),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value, String description) {
    return Tooltip(
      message: description,
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class FlightVisualization extends StatelessWidget {
  final FlightResult? flightResult;
  final Disc disc;

  const FlightVisualization({super.key, this.flightResult, required this.disc});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: flightResult == null
          ? const Center(
              child: Text('Tap "Simulate Flight" to see trajectory'),
            )
          : CustomPaint(
              size: Size.infinite,
              painter: _FlightPathPainter(flightResult: flightResult!, disc: disc),
            ),
    );
  }
}

class _FlightPathPainter extends CustomPainter {
  final FlightResult flightResult;
  final Disc disc;

  _FlightPathPainter({required this.flightResult, required this.disc});

  @override
  void paint(Canvas canvas, Size size) {
    final points = flightResult.path;
    if (points.isEmpty) return;

    // Fixed scale
    const maxDistance = 150.0;
    const maxLateral = 40.0;
    
    final availableHeight = size.height - 60;
    final availableWidth = size.width - 50;
    final scaleY = availableHeight / maxDistance;
    final scaleX = availableWidth / (maxLateral * 2);
    final centerX = (size.width - 50) / 2 + 40;
    final bottomY = size.height - 30;

    // Draw field
    _drawField(canvas, size, centerX, bottomY, scaleY);

    // Convert all points to screen coordinates
    final screenPoints = points.map((p) => Offset(
      centerX + p.z * scaleX,
      bottomY - (p.x * scaleY),
    )).toList();

    if (screenPoints.length < 2) return;

    // Draw smooth path using Catmull-Rom spline for true smoothness
    final path = _createSmoothPath(screenPoints);
    
    // Draw shadow
    final shadowPaint = Paint()
      ..color = _getPathColor().withOpacity(0.3)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, shadowPaint);
    
    // Draw main path
    final pathPaint = Paint()
      ..color = _getPathColor()
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, pathPaint);
    
    // Draw landing disc
    final landing = screenPoints.last;
    _drawDisc(canvas, landing.dx, landing.dy);
    
    // Draw thrower
    _drawThrower(canvas, screenPoints.first.dx, bottomY);
  }

  // Create a smooth path through all points using cubic Bezier curves
  Path _createSmoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    
    path.moveTo(points.first.dx, points.first.dy);
    
    if (points.length == 2) {
      path.lineTo(points.last.dx, points.last.dy);
      return path;
    }
    
    // Use cubic Bezier for smooth curves
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      
      if (i == 0) {
        // First segment - simple line to first control point
        path.lineTo(current.dx, current.dy);
      }
      
      // Calculate control points for smooth curve
      final prev = i > 0 ? points[i - 1] : current;
      final after = i < points.length - 2 ? points[i + 2] : next;
      
      // Calculate tangent vectors
      final tangentX = (next.dx - prev.dx) * 0.3;
      final tangentY = (next.dy - prev.dy) * 0.3;
      
      final cp1 = Offset(current.dx + tangentX, current.dy + tangentY);
      final cp2 = Offset(next.dx - (after.dx - current.dx) * 0.3, 
                        next.dy - (after.dy - current.dy) * 0.3);
      
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, next.dx, next.dy);
    }
    
    return path;
  }

  void _drawField(Canvas canvas, Size size, double centerX, double bottomY, double scaleY) {
    // Background
    final bgPaint = Paint()
      ..color = Colors.green.shade100
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset(0, 0) & Size(size.width - 50, size.height), bgPaint);
    
    // Center line
    final linePaint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(centerX, bottomY),
      Offset(centerX, 20),
      linePaint,
    );
    
    // Distance markers on left
    final textStyle = TextStyle(
      color: Colors.green.shade800,
      fontSize: 11,
      fontWeight: FontWeight.bold,
    );
    
    for (int d = 0; d <= 150; d += 25) {
      final y = bottomY - (d * scaleY);
      if (y < 20) break;
      
      canvas.drawLine(
        Offset(centerX - 10, y),
        Offset(centerX + 10, y),
        linePaint,
      );
      
      final textSpan = TextSpan(text: '${d}m', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }
    
    // Lateral scale at bottom
    for (int l = -30; l <= 30; l += 15) {
      if (l == 0) continue;
      final x = centerX + l * 3; // scale factor
      
      final lateralPaint = Paint()
        ..color = Colors.green.shade600
        ..strokeWidth = 1;
      
      canvas.drawLine(
        Offset(x, bottomY - 5),
        Offset(x, bottomY + 5),
        lateralPaint,
      );
      
      final textSpan = TextSpan(
        text: l > 0 ? '+$l' : '$l',
        style: TextStyle(color: Colors.green.shade700, fontSize: 9),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, bottomY + 8));
    }
  }

  void _drawThrower(Canvas canvas, double x, double y) {
    final paint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;
    
    // Triangle pointing up
    final path = Path();
    path.moveTo(x, y - 15);
    path.lineTo(x - 10, y + 5);
    path.lineTo(x + 10, y + 5);
    path.close();
    
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(x, y - 20), 6, paint);
  }

  void _drawDisc(Canvas canvas, double x, double y) {
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x + 3, y + 3), 10, shadowPaint);
    
    // Disc
    final discPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 10, discPaint);
    
    // Rim
    final rimPaint = Paint()
      ..color = Colors.red.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(x, y), 10, rimPaint);
    
    // X mark
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(Offset(x - 4, y - 4), Offset(x + 4, y + 4), crossPaint);
    canvas.drawLine(Offset(x + 4, y - 4), Offset(x - 4, y + 4), crossPaint);
  }

  Color _getPathColor() {
    if (disc.speed >= 12) return Colors.red.shade600;
    if (disc.speed >= 9) return Colors.orange.shade700;
    if (disc.speed >= 6) return Colors.blue.shade600;
    return Colors.purple.shade600;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
