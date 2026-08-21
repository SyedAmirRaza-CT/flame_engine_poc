import 'dart:ui';
import 'package:flame/components.dart';
import 'package:mental_health_game/core/utils/game_utils.dart';
import 'package:mental_health_game/features/mental_health_game/presentation/game/controllers/bird_ai_controller.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_game/features/mental_health_game/presentation/providers/bird_provider.dart';
import '../mental_health_game.dart';
import 'bird_component.dart';

class BirdClothingComponent extends SpriteAnimationComponent with HasGameReference<MentalHealthGame> {
  final BirdComponent bird;
  String? _currentAsset;

  BirdClothingComponent(this.bird) : super(size: bird.size, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    
    // Hide clothing if bird is bathing (to avoid index mismatch/visual bugs)
    if (bird.current == BirdState.bathing) {
      opacity = 0;
      return;
    } else {
      opacity = 1;
    }

    // Sync position and size to parent bird
    size = bird.size;
    position = bird.size / 2; 

    // Check if we need to load or change the clothing sprite
    final birdProvider = bird.game.buildContext?.read<BirdProvider>();
    final newAsset = birdProvider?.currentClothing;
    
    if (newAsset != _currentAsset) {
      _currentAsset = newAsset;
      if (newAsset == null || newAsset.isEmpty) {
        animation = null;
      } else {
        _loadClothingAnimation(newAsset);
      }
    }

    // Sync animation frame with the bird
    if (animation != null && bird.animation != null) {
      animationTicker?.currentIndex = bird.animationTicker?.currentIndex ?? 0;
    }
  }

  Future<void> _loadClothingAnimation(String assetPath) async {
    // The asset path coming from constants is e.g. 'birds/walking_clothes.png'
    // GameUtils.loadSpriteAnimation handles PNG/SVG based on extension
    animation = await GameUtils.loadSpriteAnimation(
      game,
      assetPath,
      columns: 3,
      rows: 3,
      stepTime: 1 / 10,
    );
    
    paint = Paint();
  }
}
