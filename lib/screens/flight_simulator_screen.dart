import 'package:flutter/material.dart';
import 'dart:math';
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

  double _getWindDirectionDegrees(String dir) {
    switch (dir) {
      case 'front': return 0;
      case 'right': return 90;
      case 'back': return 180;
      case 'left': return 270;
      default: return 0;
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
          _buildInfoCard(context),
          _buildControls(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FlightVisualization(
                flightResult: flightResult,
                disc: widget.disc,
              ),
            ),
          ),
          if (flightResult != null) _buildStats(context),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(widget.disc.name, style: Theme.of(context).textTheme.headlineSmall),
            Text('${widget.disc.brand} | ${widget.disc.flightNumbers}'),
            const SizedBox(height: 4),
            Text(_getDiscDescription(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getDiscDescription() {
    final t = widget.disc.turn;
    final f = widget.disc.fade;
    final s = widget.disc.speed;
    
    if (t < -2) return 'Very Understable - beginners, hyzer flips';
    if (t < 0 && f > 3) return 'Moderately Stable - straight flight';
    if (f > 3) return 'Overstable - reliable fade, windy';
    if (s >= 12) return 'Distance Driver - max distance';
    if (s >= 9) return 'Fairway Driver - control & distance';
    if (s >= 6) return 'Midrange - accuracy';
    return 'Putter - precision';
  }

  Widget _buildControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Wind Speed
          Row(
            children: [
              Text('Wind: ${windSpeed.toInt()} km/h', 
                style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          Slider(
            value: windSpeed,
            min: 0,
            max: 30,
            divisions: 30,
            onChanged: (v) => setState(() => windSpeed = v),
          ),
          
          // Wind Direction
          Text('Direction:', style: Theme.of(context).textTheme.bodySmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDirBtn('left', '← Left'),
              _buildDirBtn('front', '↑ Front'),
              _buildDirBtn('back', '↓ Back'),
              _buildDirBtn('right', '→ Right'),
            ],
          ),
          const SizedBox(height: 8),
          
          // Power
          Text('Power: ${throwPower.toInt()}%', 
            style: Theme.of(context).textTheme.titleSmall),
          Slider(
            value: throwPower,
            min: 30,
            max: 100,
            divisions: 70,
            onChanged: (v) => setState(() => throwPower = v),
          ),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _simulateFlight,
              child: const Text('Simulate Flight'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirBtn(String dir, String label) {
    return ElevatedButton(
      onPressed: () => setState(() => windDirection = dir),
      style: ElevatedButton.styleFrom(
        backgroundColor: windDirection == dir ? Colors.blue : Colors.grey.shade300,
        foregroundColor: windDirection == dir ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat(context, 'Distance', '${flightResult!.totalDistance.toStringAsFixed(1)}m'),
          _stat(context, 'Max Height', '${flightResult!.maxHeight.toStringAsFixed(1)}m'),
          _stat(context, 'Lateral', 
            '${flightResult!.finalLateral.abs().toStringAsFixed(1)}m ${flightResult!.finalLateral > 0 ? '→' : '←'}'),
        ],
      ),
    );
  }

  Widget _stat(BuildContext c, String label, String value) {
    return Column(
      children: [
        Text(label, style: Theme.of(c).textTheme.bodySmall),
        Text(value, style: Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
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
          ? const Center(child: Text('Tap "Simulate Flight"'))
          : CustomPaint(
              size: Size.infinite,
              painter: _FlightPainter(flightResult!, disc),
            ),
    );
  }
}

class _FlightPainter extends CustomPainter {
  final FlightResult result;
  final Disc disc;

  _FlightPainter(this.result, this.disc);

  @override
  void paint(Canvas canvas, Size size) {
    final points = result.path;
    if (points.isEmpty) return;

    const maxDist = 150.0;
    const maxLateral = 40.0;
    
    final availH = size.height - 60;
    final availW = size.width - 50;
    final scaleY = availH / maxDist;
    final scaleX = availW / (maxLateral * 2);
    final centerX = (size.width - 50) / 2 + 40;
    final bottomY = size.height - 30;

    _drawField(canvas, size, centerX, bottomY, scaleY);

    // Convert to screen coordinates
    final screenPoints = points.map((p) => Offset(
      centerX + p.y * scaleX,  // p.y is lateral
      bottomY - (p.x * scaleY), // p.x is forward distance
    )).toList();

    if (screenPoints.length < 2) return;

    // Draw smooth spline through points
    final path = _createSmoothPath(screenPoints);
    
    // Glow
    final glowPaint = Paint()
      ..color = _getColor().withOpacity(0.3)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, glowPaint);
    
    // Main path
    final paint = Paint()
      ..color = _getColor()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
    
    // Landing disc
    final end = screenPoints.last;
    _drawDisc(canvas, end.dx, end.dy);
    
    // Thrower
    _drawThrower(canvas, centerX, bottomY);
  }

  Path _createSmoothPath(List<Offset> points) {
    final path = Path();
    if (points.length < 2) return path;
    
    path.moveTo(points.first.dx, points.first.dy);
    
    // Use Catmull-Rom spline for smooth curve through all points
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : p2;
      
      // Catmull-Rom to cubic Bezier conversion
      final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6;
      
      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }
    
    return path;
  }

  void _drawField(Canvas canvas, Size size, double centerX, double bottomY, double scaleY) {
    // Background
    canvas.drawRect(
      Offset(0, 0) & Size(size.width - 50, size.height),
      Paint()..color = Colors.green.shade100,
    );
    
    // Center line
    final linePaint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(centerX, bottomY), Offset(centerX, 20), linePaint);
    
    // Distance markers on left
    final textStyle = TextStyle(color: Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.bold);
    
    for (int d = 0; d <= 150; d += 25) {
      final y = bottomY - (d * scaleY);
      if (y < 20) break;
      
      canvas.drawLine(
        Offset(centerX - 10, y), Offset(centerX + 10, y), linePaint);
      
      final tp = TextPainter(
        text: TextSpan(text: '${d}m', style: textStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(5, y - tp.height / 2));
    }
    
    // Lateral scale at bottom
    for (int l = -30; l <= 30; l += 15) {
      if (l == 0) continue;
      final x = centerX + l * 3;
      
      canvas.drawLine(
        Offset(x, bottomY - 5), Offset(x, bottomY + 5),
        Paint()..color = Colors.green.shade600..strokeWidth = 1);
      
      final tp = TextPainter(
        text: TextSpan(text: l > 0 ? '+$l' : '$l', 
          style: TextStyle(color: Colors.green.shade700, fontSize: 9)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, bottomY + 8));
    }
  }

  void _drawThrower(Canvas canvas, double x, double y) {
    final paint = Paint()..color = Colors.blue.shade700..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(x, y - 15)
      ..lineTo(x - 10, y + 5)
      ..lineTo(x + 10, y + 5)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(x, y - 20), 6, paint);
  }

  void _drawDisc(Canvas canvas, double x, double y) {
    // Shadow
    canvas.drawCircle(Offset(x + 3, y + 3), 10, 
      Paint()..color = Colors.black.withOpacity(0.3));
    
    // Body
    canvas.drawCircle(Offset(x, y), 10, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(x, y), 10, 
      Paint()..color = Colors.red.shade800..style = PaintingStyle.stroke..strokeWidth = 3);
    
    // X mark
    final cross = Paint()..color = Colors.white..strokeWidth = 2;
    canvas.drawLine(Offset(x - 4, y - 4), Offset(x + 4, y + 4), cross);
    canvas.drawLine(Offset(x + 4, y - 4), Offset(x - 4, y + 4), cross);
  }

  Color _getColor() {
    if (disc.speed >= 12) return Colors.red.shade600;
    if (disc.speed >= 9) return Colors.orange.shade700;
    if (disc.speed >= 6) return Colors.blue.shade600;
    return Colors.purple.shade600;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
