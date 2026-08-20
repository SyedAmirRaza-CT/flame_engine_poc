import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bird_providers.dart';

class BirdStatsWidget extends ConsumerWidget {
  const BirdStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bird = ref.watch(birdControllerProvider);

    if (bird == null) return const SizedBox.shrink();

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
              bird.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _StatRow(label: '❤️ Happiness', value: bird.happiness, color: Colors.red),
            _StatRow(label: '🍎 Hunger', value: bird.hunger, color: Colors.orange),
            _StatRow(label: '⚡ Energy', value: bird.energy, color: Colors.yellow[700]!),
            _StatRow(label: '💧 Cleanliness', value: bird.cleanliness, color: Colors.blue),
            const SizedBox(height: 4),
            Text('⭐ Level ${bird.level}', style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
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
