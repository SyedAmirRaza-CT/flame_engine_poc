import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../game/mental_health_game.dart';
import '../providers/bird_provider.dart';
import '../providers/mental_health_provider.dart';

class GameOptionsBottomSheet extends StatelessWidget {
  final MentalHealthGame game;

  const GameOptionsBottomSheet({super.key, required this.game});

  static void show(BuildContext context, MentalHealthGame game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GameOptionsBottomSheet(game: game),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Game Options",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Interaction Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _OptionButton(
                icon: Icons.apple,
                label: "Feed",
                onTap: () {
                  context.read<BirdProvider>().feed();
                  game.feedBird();
                  Navigator.pop(context);
                },
              ),
              _OptionButton(
                icon: Icons.waves,
                label: "Bath",
                onTap: () {
                  context.read<BirdProvider>().bath();
                  game.bathBird();
                  Navigator.pop(context);
                },
              ),
              _OptionButton(
                icon: Icons.sports_soccer,
                label: "Play",
                onTap: () {
                  game.playBird();
                  Navigator.pop(context);
                },
              ),
              _OptionButton(
                icon: Icons.bed,
                label: "Sleep",
                onTap: () {
                  game.sleepBird();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const Divider(height: 32),
          const Text("Change Background", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: GameConstants.backgrounds.map((bg) {
                return _BackgroundThumb(
                  name: bg['name']!,
                  imagePath: bg['asset']!,
                  onTap: () {
                    context.read<MentalHealthProvider>().setBackground(bg['path']!);
                    game.changeBackground(bg['path']!);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          const Divider(height: 32),
          const Text("Change Clothes", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: GameConstants.clothing.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(c['name']!),
                    onPressed: () {
                      context.read<BirdProvider>().setClothing(c['asset']!, c['name']!);
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 32),
          const Text("Settings", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Consumer<MentalHealthProvider>(
            builder: (context, provider, child) {
              return SwitchListTile(
                title: const Text("Show Collision Hitboxes", style: TextStyle(fontSize: 14)),
                value: provider.showDebugHitboxes,
                onChanged: (_) => provider.toggleDebugHitboxes(),
                secondary: const Icon(Icons.bug_report, color: Colors.orange),
                dense: true,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onTap,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: Colors.green[100],
            foregroundColor: Colors.green[800],
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _BackgroundThumb extends StatelessWidget {
  final String name;
  final String imagePath;
  final VoidCallback onTap;

  const _BackgroundThumb({required this.name, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          color: Colors.black45,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ),
    );
  }
}
