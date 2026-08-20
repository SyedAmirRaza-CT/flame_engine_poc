import 'package:equatable/equatable.dart';

enum BirdPersonality { calm, playful, curious, energetic }

class BirdProfile extends Equatable {
  final String id;
  final String name;
  final String species;
  final double happiness;
  final double hunger;
  final double energy;
  final double cleanliness;
  final int level;
  final double experience;
  final BirdPersonality personality;

  const BirdProfile({
    required this.id,
    required this.name,
    required this.species,
    this.happiness = 80.0,
    this.hunger = 0.0,
    this.energy = 100.0,
    this.cleanliness = 100.0,
    this.level = 1,
    this.experience = 0.0,
    this.personality = BirdPersonality.curious,
  });

  BirdProfile copyWith({
    String? name,
    double? happiness,
    double? hunger,
    double? energy,
    double? cleanliness,
    int? level,
    double? experience,
    BirdPersonality? personality,
  }) {
    return BirdProfile(
      id: id,
      name: name ?? this.name,
      species: species,
      happiness: happiness ?? this.happiness,
      hunger: hunger ?? this.hunger,
      energy: energy ?? this.energy,
      cleanliness: cleanliness ?? this.cleanliness,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      personality: personality ?? this.personality,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        species,
        happiness,
        hunger,
        energy,
        cleanliness,
        level,
        experience,
        personality,
      ];
}
