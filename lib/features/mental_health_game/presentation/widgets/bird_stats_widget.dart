import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/bird_controller.dart';

class BirdStatsWidget extends StatelessWidget {
  const BirdStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BirdController>(
      builder: (context, controller, child) {
        final mental_health = controller.mental_healthProfile;

        if (mental_health == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.all(16),
          color: Colors.white.withValues(alpha: 0.8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mental_health.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _StatRow(label: '❤️ Happiness', value: mental_health.happiness, color: Colors.red),
                _StatRow(label: '🍎 Hunger', value: mental_health.hunger, color: Colors.orange),
                _StatRow(label: '⚡ Energy', value: mental_health.energy, color: Colors.yellow[700]!),
                _StatRow(label: '💧 Cleanliness', value: mental_health.cleanliness, color: Colors.blue),
                const SizedBox(height: 4),
                Text('⭐ Level ${mental_health.level}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _StatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[300],
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}
