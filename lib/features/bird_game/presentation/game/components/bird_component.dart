import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../../../../core/constants/constants.dart';
import '../controllers/bird_ai_controller.dart';
import '../bird_game.dart';
import 'pond_component.dart';

class BirdComponent extends SpriteAnimationComponent with CollisionCallbacks, HasGameReference<BirdGame> {
  Vector2? _target;
  double _speed = 0;
  late BirdAIController ai;

  BirdComponent() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    ai = BirdAIController(this);
    add(ai);
    
    await _loadAnimations();
  }

  Future<void> _loadAnimations() async {
    final image = await game.images.load(
      'bird.png',
    );

    const columns = 3;
    const rows = 3;

    final frameWidth = image.width / columns;
    final frameHeight = image.height / rows;

    final frames = <SpriteAnimationFrameData>[];

    for (int row = 0; row < rows; row++) {
      frames.add(
        SpriteAnimationFrameData(
          srcPosition: Vector2(
            0, // column 0
            row * frameHeight,
          ),
          srcSize: Vector2(
            frameWidth,
            frameHeight,
          ),
          stepTime: 1 /3,
        ),
      );
    }

    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData(frames),
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PondComponent) {
      if (ai.currentState == BirdState.flying || ai.currentState == BirdState.walking) {
        ai.forceState(BirdState.bathing, duration: 5.0);
        stopMoving();
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_target != null) {
      final direction = (_target! - position).normalized();
      final distance = position.distanceTo(_target!);
      
      if (distance < 5) {
        _target = null;
      } else {
        position += direction * _speed * dt;
        // Simple rotation towards movement
        angle = direction.angleToSigned(Vector2(0, -1)) * -1;
      }
    }
    
    // Keep bird within world bounds
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;
    position.x = position.x.clamp(halfWidth, GameConstants.worldWidth - halfWidth);
    position.y = position.y.clamp(halfHeight, GameConstants.worldHeight - halfHeight);
  }

  void setTarget(Vector2 target, double speed) {
    _target = target;
    _speed = speed;
  }

  void stopMoving() {
    _target = null;
    _speed = 0;
  }

  Vector2? get target => _target;

  void onFeed() {
    // For MVP: stop and "eat"
    ai.forceState(BirdState.eating, duration: 3.0);
    _target = null;
  }

  void onBath() {
    // Go to pond
    ai.forceState(
      BirdState.flying,
      target: Vector2(GameConstants.pondX, GameConstants.pondY),
      speed: GameConstants.birdFlySpeed,
      duration: 10.0,
    );
  }
}
