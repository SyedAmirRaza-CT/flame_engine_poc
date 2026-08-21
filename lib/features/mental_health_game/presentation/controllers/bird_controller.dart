import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/bird_profile.dart';
import '../../domain/repositories/bird_repository.dart';

class BirdController extends ChangeNotifier {
  final BirdRepository repository;
  BirdProfile? _mental_healthProfile;
  Timer? _statsTimer;

  BirdController({required this.repository}) {
    _startStatsTimer();
  }

  BirdProfile? get mental_healthProfile => _mental_healthProfile;

  void _startStatsTimer() {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      updateStats(5);
      save();
    });
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    super.dispose();
  }

  Future<void> loadMentalHealth() async {
    _mental_healthProfile = await repository.getBirdProfile();
    notifyListeners();
  }

  Future<void> createMentalHealth(String name) async {
    final newMentalHealth = BirdProfile(
      id: const Uuid().v4(),
      name: name,
      species: 'Sparrow',
    );
    _mental_healthProfile = newMentalHealth;
    notifyListeners();
    await repository.saveBirdProfile(newMentalHealth);
  }

  Future<void> feed() async {
    if (_mental_healthProfile == null) return;
    
    _mental_healthProfile = _mental_healthProfile!.copyWith(
      happiness: (_mental_healthProfile!.happiness + 10).clamp(0, 100),
      hunger: (_mental_healthProfile!.hunger - 15).clamp(0, 100),
    );
    notifyListeners();
    await repository.saveBirdProfile(_mental_healthProfile!);
  }

  Future<void> bath() async {
    if (_mental_healthProfile == null) return;

    _mental_healthProfile = _mental_healthProfile!.copyWith(
      cleanliness: (_mental_healthProfile!.cleanliness + 20).clamp(0, 100),
      happiness: (_mental_healthProfile!.happiness + 5).clamp(0, 100),
    );
    notifyListeners();
    await repository.saveBirdProfile(_mental_healthProfile!);
  }

  Future<void> updateStats(double dt) async {
    if (_mental_healthProfile == null) return;

    _mental_healthProfile = _mental_healthProfile!.copyWith(
      hunger: (_mental_healthProfile!.hunger + 0.5 * dt).clamp(0, 100),
      energy: (_mental_healthProfile!.energy - 0.3 * dt).clamp(0, 100),
      cleanliness: (_mental_healthProfile!.cleanliness - 0.2 * dt).clamp(0, 100),
      happiness: (_mental_healthProfile!.happiness - 0.1 * dt).clamp(0, 100),
    );
    notifyListeners();
  }
  
  Future<void> save() async {
    if (_mental_healthProfile != null) {
      await repository.saveBirdProfile(_mental_healthProfile!);
    }
  }
}
