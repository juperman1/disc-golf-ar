import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disc Golf AR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Disc Golf Discs'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, dynamic>> discs = const [
    {'name': 'Destroyer', 'brand': 'Innova', 'speed': 12, 'glide': 5, 'turn': -1, 'fade': 3},
    {'name': 'Buzzz', 'brand': 'Discraft', 'speed': 5, 'glide': 4, 'turn': -1, 'fade': 1},
    {'name': 'Judge', 'brand': 'Dynamic', 'speed': 2, 'glide': 4, 'turn': 0, 'fade': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder( // Fixed
        itemCount: discs.length,
        itemBuilder: (context, index) {
          final disc = discs[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.disc_full),
              title: Text(disc['name'] as String),
              subtitle: Text('${disc['brand']} | Speed: ${disc['speed']}'),
              trailing: Text('${disc['turn']}/${disc['fade']}'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(disc['name'] as String),
                    content: Text(
                      'Speed: ${disc['speed']}\n'
                      'Glide: ${disc['glide']}\n'
                      'Turn: ${disc['turn']}\n'
                      'Fade: ${disc['fade']}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
