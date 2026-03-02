import 'package:flutter/material.dart';

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

  final List<Map<String, dynamic>> discs = const [
    {'name': 'Destroyer', 'brand': 'Innova', 'speed': 12, 'glide': 5, 'turn': -1, 'fade': 3},
    {'name': 'Buzzz', 'brand': 'Discraft', 'speed': 5, 'glide': 4, 'turn': -1, 'fade': 1},
    {'name': 'Judge', 'brand': 'Dynamic', 'speed': 2, 'glide': 4, 'turn': 0, 'fade': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disc Golf Discs'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: discs.length,
        itemBuilder: (context, index) {
          final disc = discs[index];
          return ListTile(
            leading: const Icon(Icons.disc_full),
            title: Text(disc['name']),
            subtitle: Text('${disc['brand']} | Speed: ${disc['speed']}'),
            trailing: Text('${disc['turn']}/${disc['fade']}'),
          );
        },
      ),
    );
  }
}