import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/mental_health_game.dart';
import '../controllers/bird_controller.dart';

class GameUIOverlay extends StatelessWidget {
  final MentalHealthGame game;

  const GameUIOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              context.read<BirdController>().feed();
              game.feedMentalHealth();
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
              context.read<BirdController>().bath();
              game.bathMentalHealth();
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
