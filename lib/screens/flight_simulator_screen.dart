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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat('Distance', '${flightResult!.totalDistance.toStringAsFixed(1)}m', 'How far the disc flies'),
                      _buildStat('Max Height', '${flightResult!.maxHeight.toStringAsFixed(1)}m', 'Highest point in flight'),
                      _buildStat('Lateral', '${flightResult!.finalLateral.abs().toStringAsFixed(1)}m ${_getLateralDirection()}', 'Left/right from target'),
                    ],
                  ),
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
    final path = flightResult.path;
    if (path.isEmpty) return;

    // Fixed scale: always show up to 150m
    const maxDistance = 150.0;
    const maxLateral = 40.0; // 40m left/right
    
    // Calculate scales
    final availableHeight = size.height - 60; // Leave space for labels
    final availableWidth = size.width - 50; // Leave space for scale
    final scaleY = availableHeight / maxDistance;
    final scaleX = availableWidth / (maxLateral * 2);
    final centerX = (size.width - 50) / 2 + 40; // Offset for left scale
    final bottomY = size.height - 30;

    // Draw field
    _drawField(canvas, size, centerX, bottomY, scaleY, maxDistance);

    // Draw smooth flight path using curves
    final pathPaint = Paint()
      ..color = _getPathColor()
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (path.length >= 2) {
      final flightPath = Path();
      
      // Start from thrower
      final startZ = path.first.z;
      final startScreenX = centerX + startZ * scaleX;
      final startScreenY = bottomY - (path.first.x * scaleY);
      flightPath.moveTo(startScreenX, startScreenY);
      
      // Draw smooth curve through points
      for (int i = 1; i < path.length - 1; i++) {
        final p0 = path[i];
        final p1 = path[i + 1];
        
        final x = centerX + p0.z * scaleX;
        final y = bottomY - (p0.x * scaleY);
        
        final nextX = centerX + p1.z * scaleX;
        final nextY = bottomY - (p1.x * scaleY);
        
        // Use quadratic bezier for smooth curves
        final midX = (x + nextX) / 2;
        final midY = (y + nextY) / 2;
        
        flightPath.quadraticBezierTo(x, y, midX, midY);
      }
      
      // Draw to final point
      final last = path.last;
      final lastX = centerX + last.z * scaleX;
      final lastY = bottomY - (last.x * scaleY);
      flightPath.lineTo(lastX, lastY);
      
      // Draw shadow/glow for flight path
      final shadowPaint = Paint()
        ..color = _getPathColor().withOpacity(0.3)
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(flightPath, shadowPaint);
      
      // Draw main flight path
      canvas.drawPath(flightPath, pathPaint);
      
      // Draw landing disc
      _drawDisc(canvas, lastX, lastY);
    }
    
    // Draw thrower at bottom
    _drawThrower(canvas, centerX, bottomY);
  }

  void _drawField(Canvas canvas, Size size, double centerX, double bottomY, double scaleY, double maxDistance) {
    // Draw grass background
    final bgPaint = Paint()
      ..color = Colors.green.shade100
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset(0, 0) & Size(size.width - 50, size.height), bgPaint);
    
    // Draw center throwing line
    final linePaint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(centerX, bottomY),
      Offset(centerX, 20),
      linePaint,
    );
    
    // Draw distance scale on the LEFT side
    final textStyle = TextStyle(
      color: Colors.green.shade800,
      fontSize: 11,
      fontWeight: FontWeight.bold,
    );
    
    // Distance markers every 25m
    for (int d = 0; d <= maxDistance; d += 25) {
      final y = bottomY - (d * scaleY);
      if (y < 20) break;
      
      // Horizontal tick line
      canvas.drawLine(
        Offset(centerX - 10, y),
        Offset(centerX + 10, y),
        linePaint,
      );
      
      // Label on the left
      final textSpan = TextSpan(text: '${d}m', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }
    
    // Draw lateral scale at bottom (left/right indicators)
    final lateralPaint = Paint()
      ..color = Colors.green.shade600
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Draw left/right markers
    for (int l = -30; l <= 30; l += 15) {
      if (l == 0) continue;
      final x = centerX + l * ((size.width - 90) / 80);
      
      canvas.drawLine(
        Offset(x, bottomY - 5),
        Offset(x, bottomY + 5),
        lateralPaint,
      );
      
      final textSpan = TextSpan(
        text: '${l > 0 ? '+' : ''}$l',
        style: TextStyle(color: Colors.green.shade700, fontSize: 9),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, bottomY + 8));
    }
  }

  void _drawThrower(Canvas canvas, double x, double y) {
    // Draw person icon (triangle for player)
    final personPaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(x, y - 15);
    path.lineTo(x - 10, y + 5);
    path.lineTo(x + 10, y + 5);
    path.close();
    
    canvas.drawPath(path, personPaint);
    
    // Draw circle head
    canvas.drawCircle(Offset(x, y - 20), 6, personPaint);
  }

  void _drawDisc(Canvas canvas, double x, double y) {
    // Draw disc with shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x + 3, y + 3), 10, shadowPaint);
    
    // Draw disc body
    final discPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 10, discPaint);
    
    // Draw disc rim
    final rimPaint = Paint()
      ..color = Colors.red.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(x, y), 10, rimPaint);
    
    // Draw "X" for disc
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(Offset(x - 4, y - 4), Offset(x + 4, y + 4), crossPaint);
    canvas.drawLine(Offset(x + 4, y - 4), Offset(x - 4, y + 4), crossPaint);
  }

  Color _getPathColor() {
    // Color based on flight characteristics
    if (disc.speed >= 12) return Colors.red.shade600; // Distance driver
    if (disc.speed >= 9) return Colors.orange.shade700; // Fairway
    if (disc.speed >= 6) return Colors.blue.shade600; // Midrange
    return Colors.purple.shade600; // Putter
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
