import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/bird_profile.dart';
import '../../domain/repositories/bird_repository.dart';

class BirdController extends StateNotifier<BirdProfile?> {
  final BirdRepository repository;
  Timer? _statsTimer;

  BirdController({required this.repository}) : super(null) {
    _startStatsTimer();
  }

  void _startStatsTimer() {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      updateStats(5); // Update every 5 seconds
      save(); // Auto-save periodically
    });
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    super.dispose();
  }

  Future<void> loadBird() async {
    state = await repository.getBirdProfile();
  }

  Future<void> createBird(String name) async {
    final newBird = BirdProfile(
      id: const Uuid().v4(),
      name: name,
      species: 'Sparrow',
    );
    state = newBird;
    await repository.saveBirdProfile(newBird);
  }

  Future<void> feed() async {
    if (state == null) return;
    
    final newState = state!.copyWith(
      happiness: (state!.happiness + 10).clamp(0, 100),
      hunger: (state!.hunger - 15).clamp(0, 100),
    );
    state = newState;
    await repository.saveBirdProfile(newState);
  }

  Future<void> bath() async {
    if (state == null) return;

    final newState = state!.copyWith(
      cleanliness: (state!.cleanliness + 20).clamp(0, 100),
      happiness: (state!.happiness + 5).clamp(0, 100),
    );
    state = newState;
    await repository.saveBirdProfile(newState);
  }

  Future<void> updateStats(double dt) async {
    if (state == null) return;

    // Gradual decay of stats over time
    final newState = state!.copyWith(
      hunger: (state!.hunger + 0.5 * dt).clamp(0, 100),
      energy: (state!.energy - 0.3 * dt).clamp(0, 100),
      cleanliness: (state!.cleanliness - 0.2 * dt).clamp(0, 100),
      happiness: (state!.happiness - 0.1 * dt).clamp(0, 100),
    );
    state = newState;
  }
  
  Future<void> save() async {
    if (state != null) {
      await repository.saveBirdProfile(state!);
    }
  }
}
