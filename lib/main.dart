import 'package:flutter/material.dart';
import 'models/disc.dart';
import 'screens/flight_simulator_screen.dart';

void main() {
  runApp(const DiscGolfApp());
}

class DiscGolfApp extends StatelessWidget {
  const DiscGolfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disc Golf AR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const DiscListScreen(),
    );
  }
}

class DiscListScreen extends StatelessWidget {
  const DiscListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disc Golf Discs'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: allDiscs.length,
        itemBuilder: (context, index) {
          final disc = allDiscs[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.disc_full),
              title: Text(disc.name),
              subtitle: Text(disc.brand),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDiscColor(disc.speed),
                  borderRadius: BorderRadius.circular(8),
                ),
              child: Text(
                disc.flightNumbers,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlightSimulatorScreen(disc: disc),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}

  Color _getDiscColor(int speed) {
    if (speed >= 10) return Colors.red;
    if (speed >= 7) return Colors.orange;
    if (speed >= 4) return Colors.blue;
    return Colors.green;
  }
}
