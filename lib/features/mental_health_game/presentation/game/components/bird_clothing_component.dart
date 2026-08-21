import 'dart:ui';
import 'package:flame/components.dart';
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
    final image = await game.images.load(assetPath);
    
    // The asset 'birds/flying_clothes.png' is already correctly colored.
    paint = Paint();

    const columns = 3;
    const rows = 3;
    final frameWidth = image.width / columns;
    final frameHeight = image.height / rows;

    final frames = <SpriteAnimationFrameData>[];
    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        frames.add(
          SpriteAnimationFrameData(
            srcPosition: Vector2(column * frameWidth, row * frameHeight),
            srcSize: Vector2(frameWidth, frameHeight),
            stepTime: 1 / 10,
          ),
        );
      }
    }

    animation = SpriteAnimation.fromFrameData(image, SpriteAnimationData(frames));
  }
}
