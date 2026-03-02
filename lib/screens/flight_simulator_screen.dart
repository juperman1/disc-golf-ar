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
  List<FlightPoint>? flightPath;

  void _simulateFlight() {
    final simulator = FlightSimulator(
      disc: widget.disc,
      windSpeed: windSpeed,
      windDirection: windDirection,
      throwPower: throwPower / 100,
    );
    setState(() {
      flightPath = simulator.simulate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.disc.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Brand: ${widget.disc.brand}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Flight Numbers: ${widget.disc.flightNumbers}', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            _buildWindControls(),
            const SizedBox(height: 16),
            _buildPowerSlider(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _simulateFlight,
                child: const Text('Simulate Flight'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: flightPath == null 
                ? const Center(child: Text('Tap "Simulate Flight" to see trajectory'))
                : FlightPathPainter(flightPath: flightPath!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wind: ${windSpeed.toStringAsFixed(0)} km/h from $windDirection'),
        Slider(
          value: windSpeed,
          min: 0,
          max: 30,
          divisions: 30,
          label: windSpeed.toStringAsFixed(0),
          onChanged: (value) => setState(() => windSpeed = value),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDirectionButton('front', 'Front'),
            _buildDirectionButton('right', 'Right'),
            _buildDirectionButton('back', 'Back'),
            _buildDirectionButton('left', 'Left'),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionButton(String direction, String label) {
    return ElevatedButton(
      onPressed: () => setState(() => windDirection = direction),
      style: ElevatedButton.styleFrom(
        backgroundColor: windDirection == direction ? Colors.blue : Colors.grey,
      ),
      child: Text(label),
    );
  }

  Widget _buildPowerSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Throw Power: ${throwPower.toStringAsFixed(0)}%'),
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
}

class FlightPathPainter extends StatelessWidget {
  final List<FlightPoint> flightPath;

  const FlightPathPainter({super.key, required this.flightPath});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: _FlightPathPainter(flightPath: flightPath),
    );
  }
}

class _FlightPathPainter extends CustomPainter {
  final List<FlightPoint> flightPath;

  _FlightPathPainter({required this.flightPath});

  @override
  void paint(Canvas canvas, Size size) {
    if (flightPath.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final scaleX = size.width / 100;
    final scaleY = size.height / 50;

    path.moveTo(0, size.height - flightPath[0].y * scaleY);

    for (int i = 1; i < flightPath.length; i++) {
      path.lineTo(
        flightPath[i].x * scaleX,
        size.height - flightPath[i].y * scaleY,
      );
    }

    canvas.drawPath(path, paint);

    // Draw disc at end position
    final endPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(flightPath.last.x * scaleX, size.height - flightPath.last.y * scaleY),
      8,
      endPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
