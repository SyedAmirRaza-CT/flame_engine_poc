import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bird_providers.dart';
import '../game/bird_game.dart';

class GameUIOverlay extends ConsumerWidget {
  final BirdGame game;

  const GameUIOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              ref.read(birdControllerProvider.notifier).feed();
              // Trigger a seed drop in a random location near the bird
              game.feedBird();
            },
            icon: const Icon(Icons.apple),
            label: const Text('FEED'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[100],
              foregroundColor: Colors.orange[900],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(birdControllerProvider.notifier).bath();
              game.bathBird();
            },
            icon: const Icon(Icons.waves),
            label: const Text('BATH'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[100],
              foregroundColor: Colors.blue[900],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
