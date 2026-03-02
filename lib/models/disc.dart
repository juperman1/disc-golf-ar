class Disc {
  final String name;
  final String brand;
  final int speed;
  final int glide;
  final int turn;
  final int fade;

  const Disc({
    required this.name,
    required this.brand,
    required this.speed,
    required this.glide,
    required this.turn,
    required this.fade,
  });

  String get flightNumbers => '$speed|$glide|$turn|$fade';
}

final List<Disc> allDiscs = const [
  // Distance Drivers
  Disc(name: 'Destroyer', brand: 'Innova', speed: 12, glide: 5, turn: -1, fade: 3),
  Disc(name: 'Boss', brand: 'Innova', speed: 13, glide: 5, turn: 0, fade: 3),
  Disc(name: 'Wraith', brand: 'Innova', speed: 11, glide: 5, turn: -1, fade: 3),
  Disc(name: 'Force', brand: 'Discraft', speed: 12, glide: 5, turn: 0, fade: 3),
  Disc(name: 'Zeus', brand: 'Discraft', speed: 12, glide: 5, turn: -1, fade: 3),
  
  // Fairway Drivers
  Disc(name: 'TeeBird', brand: 'Innova', speed: 7, glide: 5, turn: 0, fade: 2),
  Disc(name: 'Leopard', brand: 'Innova', speed: 6, glide: 5, turn: -2, fade: 1),
  Disc(name: 'Escape', brand: 'Dynamic Discs', speed: 9, glide: 5, turn: -1, fade: 2),
  Disc(name: 'Saint', brand: 'Latitude 64', speed: 9, glide: 6, turn: -1, fade: 2),
  Disc(name: 'Crave', brand: 'Axiom', speed: 6, glide: 5, turn: -1, fade: 1),
  
  // Midranges
  Disc(name: 'Buzzz', brand: 'Discraft', speed: 5, glide: 4, turn: -1, fade: 1),
  Disc(name: 'Roc3', brand: 'Innova', speed: 5, glide: 4, turn: 0, fade: 3),
  Disc(name: 'Mako3', brand: 'Innova', speed: 5, glide: 5, turn: 0, fade: 0),
  Disc(name: 'Truth', brand: 'Dynamic Discs', speed: 5, glide: 5, turn: -1, fade: 1),
  Disc(name: 'Verdict', brand: 'Dynamic Discs', speed: 5, glide: 4, turn: 0, fade: 3),
  Disc(name: 'Comet', brand: 'Discraft', speed: 4, glide: 5, turn: -2, fade: 1),
  
  // Putters
  Disc(name: 'Judge', brand: 'Dynamic Discs', speed: 2, glide: 4, turn: 0, fade: 1),
  Disc(name: 'Wizard', brand: 'Gateway', speed: 2, glide: 3, turn: 0, fade: 2),
  Disc(name: 'Aviar', brand: 'Innova', speed: 2, glide: 3, turn: 0, fade: 1),
  Disc(name: 'Envy', brand: 'Axiom', speed: 3, glide: 3, turn: 0, fade: 2),
];
