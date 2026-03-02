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
        return 90; // from right (blows to left)
      case 'back':
        return 180; // tailwind
      case 'left':
        return 270; // from left (blows to right)
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
          
          // Stats
          if (flightResult != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat('Distance', '${flightResult!.totalDistance.toStringAsFixed(1)}m'),
                  _buildStat('Max Height', '${flightResult!.maxHeight.toStringAsFixed(1)}m'),
                  _buildStat('Lateral', '${flightResult!.finalLateral.toStringAsFixed(1)}m'),
                ],
              ),
            ),
        ],
      ),
    );
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

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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

    // Draw field/grid
    _drawField(canvas, size);

    // Calculate scales
    // X (forward) maps to Y-axis on screen (bottom to top)
    // Z (lateral) maps to X-axis on screen (centered)
    final maxX = flightResult.totalDistance * 1.1;
    final maxZ = 30.0; // meters left/right
    
    final scaleY = size.height / maxX;
    final scaleX = size.width / (maxZ * 2);
    final centerX = size.width / 2;

    // Draw flight path
    final pathPaint = Paint()
      ..color = _getPathColor()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final flightPath = Path();
    bool first = true;
    
    for (final point in path) {
      final screenX = centerX + point.z * scaleX;
      final screenY = size.height - (point.x * scaleY) - 20; // Offset from bottom
      
      if (first) {
        flightPath.moveTo(screenX, screenY);
        first = false;
      } else {
        flightPath.lineTo(screenX, screenY);
      }
    }
    
    canvas.drawPath(flightPath, pathPaint);

    // Draw start position (thrower)
    final startPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(centerX, size.height - 20),
      6,
      startPaint,
    );
    
    // Draw end position (landing)
    final endPoint = path.last;
    final endX = centerX + endPoint.z * scaleX;
    final endY = size.height - (endPoint.x * scaleY) - 20;
    
    final endPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(endX, endY),
      8,
      endPaint,
    );
    
    // Draw disc icon at landing
    final discPaint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(endX, endY), 12, discPaint);
  }

  void _drawField(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()
      ..color = Colors.green.shade100
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);
    
    // Center line (throw direction)
    final linePaint = Paint()
      ..color = Colors.green.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    final centerX = size.width / 2;
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      linePaint,
    );
    
    // Distance markers (every 25m)
    final maxDistance = flightResult.totalDistance * 1.2;
    final scaleY = size.height / (maxDistance * 1.1);
    
    final textStyle = TextStyle(
      color: Colors.green.shade700,
      fontSize: 10,
    );
    
    for (int d = 25; d <= maxDistance; d += 25) {
      final y = size.height - (d * scaleY) - 20;
      if (y < 0) break;
      
      canvas.drawLine(
        Offset(centerX - 5, y),
        Offset(centerX + 5, y),
        linePaint,
      );
      
      final textSpan = TextSpan(text: '${d}m', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(centerX + 8, y - textPainter.height / 2));
    }
  }

  Color _getPathColor() {
    // Color based on flight characteristics
    if (disc.speed >= 12) return Colors.red; // Distance driver
    if (disc.speed >= 9) return Colors.orange; // Fairway
    if (disc.speed >= 6) return Colors.blue; // Midrange
    return Colors.purple; // Putter
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
