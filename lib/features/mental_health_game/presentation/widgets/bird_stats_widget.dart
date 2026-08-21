import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bird_provider.dart';

class BirdStatsWidget extends StatelessWidget {
  const BirdStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BirdProvider>(
      builder: (context, birdProvider, child) {
        final bird = birdProvider.birdProfile;

        if (bird == null) return const SizedBox.shrink();

        return SizedBox(
          width: 120, // Keep it narrow
          child: Card(
            margin: const EdgeInsets.all(8),
            color: Colors.white.withValues(alpha: 0.7),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bird.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 8, thickness: 0.5),
                  _StatRow(icon: '❤️', value: bird.happiness, color: Colors.red),
                  _StatRow(icon: '🍎', value: bird.hunger, color: Colors.orange),
                  _StatRow(icon: '⚡', value: bird.energy, color: Colors.yellow[700]!),
                  _StatRow(icon: '💧', value: bird.cleanliness, color: Colors.blue),
                  const SizedBox(height: 2),
                  Text('Lvl ${bird.level}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  final String icon;
  final double value;
  final Color color;

  const _StatRow({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: Colors.grey[300],
                color: color,
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
