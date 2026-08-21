import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/entities/bird_profile.dart';
import '../../domain/repositories/bird_repository.dart';

class BirdProvider extends ChangeNotifier {
  final BirdRepository repository;
  BirdProfile? _birdProfile;
  Timer? _statsTimer;
  String? _currentClothing; 
  String? _currentClothingName;

  BirdProvider({required this.repository}) {
    _startStatsTimer();
  }

  BirdProfile? get birdProfile => _birdProfile;
  String? get currentClothing => _currentClothing;
  String? get currentClothingName => _currentClothingName;

  void setClothing(String? assetPath, String? name) {
    _currentClothing = assetPath;
    _currentClothingName = name;
    notifyListeners();
  }

  void _startStatsTimer() {
    _statsTimer?.cancel();
    // Update every 2 seconds for smoother UI
    _statsTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      updateStats(2);
      save();
    });
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    super.dispose();
  }

  Future<void> loadBird() async {
    _birdProfile = await repository.getBirdProfile();
    notifyListeners();
  }

  Future<void> createBird(String name) async {
    final newBird = BirdProfile(
      id: const Uuid().v4(),
      name: name,
      species: 'Sparrow',
    );
    _birdProfile = newBird;
    notifyListeners();
    await repository.saveBirdProfile(newBird);
  }

  Future<void> feed() async {
    if (_birdProfile == null) return;
    
    _birdProfile = _birdProfile!.copyWith(
      happiness: (_birdProfile!.happiness + 15).clamp(0, 100),
      hunger: (_birdProfile!.hunger - 30).clamp(0, 100),
    );
    notifyListeners();
    await repository.saveBirdProfile(_birdProfile!);
  }

  Future<void> bath() async {
    if (_birdProfile == null) return;

    _birdProfile = _birdProfile!.copyWith(
      cleanliness: (_birdProfile!.cleanliness + 40).clamp(0, 100),
      happiness: (_birdProfile!.happiness + 10).clamp(0, 100),
    );
    notifyListeners();
    await repository.saveBirdProfile(_birdProfile!);
  }

  Future<void> play() async {
    if (_birdProfile == null) return;

    _birdProfile = _birdProfile!.copyWith(
      happiness: (_birdProfile!.happiness + 25).clamp(0, 100),
      energy: (_birdProfile!.energy - 20).clamp(0, 100),
      hunger: (_birdProfile!.hunger + 10).clamp(0, 100),
    );
    notifyListeners();
    await repository.saveBirdProfile(_birdProfile!);
  }

  Future<void> sleep() async {
    if (_birdProfile == null) return;

    _birdProfile = _birdProfile!.copyWith(
      energy: (_birdProfile!.energy + 50).clamp(0, 100),
      hunger: (_birdProfile!.hunger + 15).clamp(0, 100),
    );
    notifyListeners();
    await repository.saveBirdProfile(_birdProfile!);
  }

  Future<void> updateStats(double dt) async {
    if (_birdProfile == null) return;

    // Based on GameConstants.fullCycleSeconds (e.g., 600s = 24h)
    // Scale factor: 1 real second = (24 * 3600) / fullCycleSeconds game seconds
    final double timeScale = (24 * 3600) / GameConstants.fullCycleSeconds;
    
    // Per Game Day (24h) Decay/Increase
    // Hunger: +150 per day (needs eating ~2 times)
    // Energy: -120 per day (needs sleeping ~1.2 times)
    // Cleanliness: -100 per day (needs bathing once)
    // Happiness: -80 per day (natural decay)

    const double hungerRatePerGameDay = 150.0;
    const double energyRatePerGameDay = -120.0;
    const double cleanlinessRatePerGameDay = -100.0;
    const double happinessRatePerGameDay = -80.0;

    // Convert to per-real-second rates
    final double hungerRate = (hungerRatePerGameDay / (24 * 3600)) * timeScale;
    final double energyRate = (energyRatePerGameDay / (24 * 3600)) * timeScale;
    final double cleanlinessRate = (cleanlinessRatePerGameDay / (24 * 3600)) * timeScale;
    final double happinessRate = (happinessRatePerGameDay / (24 * 3600)) * timeScale;

    _birdProfile = _birdProfile!.copyWith(
      hunger: (_birdProfile!.hunger + hungerRate * dt).clamp(0, 100),
      energy: (_birdProfile!.energy + energyRate * dt).clamp(0, 100),
      cleanliness: (_birdProfile!.cleanliness + cleanlinessRate * dt).clamp(0, 100),
      happiness: (_birdProfile!.happiness + happinessRate * dt).clamp(0, 100),
    );
    notifyListeners();
  }
  
  Future<void> save() async {
    if (_birdProfile != null) {
      await repository.saveBirdProfile(_birdProfile!);
    }
  }
}
