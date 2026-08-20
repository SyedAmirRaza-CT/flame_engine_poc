import '../../domain/entities/bird_profile.dart';

class BirdProfileModel extends BirdProfile {
  const BirdProfileModel({
    required super.id,
    required super.name,
    required super.species,
    super.happiness,
    super.hunger,
    super.energy,
    super.cleanliness,
    super.level,
    super.experience,
    super.personality,
  });

  factory BirdProfileModel.fromJson(Map<String, dynamic> json) {
    return BirdProfileModel(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      happiness: (json['happiness'] as num).toDouble(),
      hunger: (json['hunger'] as num).toDouble(),
      energy: (json['energy'] as num).toDouble(),
      cleanliness: (json['cleanliness'] as num).toDouble(),
      level: json['level'] as int,
      experience: (json['experience'] as num).toDouble(),
      personality: BirdPersonality.values.firstWhere(
        (e) => e.name == json['personality'],
        orElse: () => BirdPersonality.curious,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'happiness': happiness,
      'hunger': hunger,
      'energy': energy,
      'cleanliness': cleanliness,
      'level': level,
      'experience': experience,
      'personality': personality.name,
    };
  }

  factory BirdProfileModel.fromEntity(BirdProfile entity) {
    return BirdProfileModel(
      id: entity.id,
      name: entity.name,
      species: entity.species,
      happiness: entity.happiness,
      hunger: entity.hunger,
      energy: entity.energy,
      cleanliness: entity.cleanliness,
      level: entity.level,
      experience: entity.experience,
      personality: entity.personality,
    );
  }
}
