import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/constants.dart';

import 'package:mental_health_game/features/mental_health_game/domain/entities/bird_profile.dart';
import 'package:mental_health_game/features/mental_health_game/presentation/providers/bird_provider.dart';

import '../mental_health_game.dart';
import '../controllers/bird_ai_controller.dart';
import 'pond_component.dart';
import 'bird_status_component.dart';
import 'bird_clothing_component.dart';

enum BirdAreaIntent { none, pond }

class BirdComponent extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<MentalHealthGame> {
  Vector2? _target;
  double _speed = 0;

  late BirdAIController ai;
  BirdProfile? currentProfile;

  // The intent with which the bird is moving.
  // If 'none', it's just autonomous wandering and should avoid special areas.
  BirdAreaIntent currentIntent = BirdAreaIntent.none;

  BirdComponent({super.key}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // ----------------------------------------------------------
    // BIRD HITBOX
    // ----------------------------------------------------------
    //
    // Don't use the entire bird image as collision area.
    // Keep the hitbox smaller so the bird doesn't hit trees
    // when its transparent/outer sprite area touches them.
    //

    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.45, size.y * 0.45),
        position: Vector2(size.x * 0.275, size.y * 0.30),
      ),
    );

    // ----------------------------------------------------------
    // AI
    // ----------------------------------------------------------

    ai = BirdAIController(this);

    add(ai);

    // ----------------------------------------------------------
    // STATUS INDICATORS
    // ----------------------------------------------------------

    add(BirdStatusComponent(this));

    // ----------------------------------------------------------
    // CLOTHING OVERLAY
    // ----------------------------------------------------------

    add(BirdClothingComponent(this));

    // ----------------------------------------------------------
    // ANIMATION
    // ----------------------------------------------------------

    await _loadAnimations();
  }

  // ============================================================
  // ANIMATION
  // ============================================================

  Future<void> _loadAnimations() async {
    final image = await game.images.load('birds/flying.png');

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

    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData(frames),
    );
  }

  // ============================================================
  // COLLISION
  // ============================================================

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // ----------------------------------------------------------
    // POND
    // ----------------------------------------------------------

    if (other is PondComponent) {
      if (currentIntent == BirdAreaIntent.pond) {
        stopMoving();
        currentIntent = BirdAreaIntent.none;
        ai.forceState(BirdState.bathing, duration: 5.0);
      } else {
        _avoidArea(other.position);
      }
      return;
    }
  }

  void _avoidArea(Vector2 areaPosition) {
    // Push the bird away from areas it's not supposed to be in
    final Vector2 pushDirection = (position - areaPosition).normalized();
    position += pushDirection * 15;

    // If it was wandering, give it a new random target to get away
    if (currentIntent == BirdAreaIntent.none) {
      ai.chooseNewRandomTarget();
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    // Sync profile from Provider
    if (game.buildContext != null) {
      currentProfile = game.buildContext!.read<BirdProvider>().birdProfile;
    }

    // ----------------------------------------------------------
    // AI MOVEMENT
    // ----------------------------------------------------------

    if (_target != null) {
      final Vector2 direction = (_target! - position).normalized();

      final double distance = position.distanceTo(_target!);

      if (distance < 5) {
        _target = null;
        _speed = 0;
      } else {
        position += direction * _speed * dt;
      }
    }

    _keepInsideWorld();
  }

  // ============================================================
  // KEEP BIRD INSIDE WORLD
  // ============================================================

  void _keepInsideWorld() {
    final double halfWidth = size.x / 2;

    final double halfHeight = size.y / 2;

    position.x = position.x.clamp(
      halfWidth,
      GameConstants.worldWidth - halfWidth,
    );

    position.y = position.y.clamp(
      halfHeight,
      GameConstants.worldHeight - halfHeight,
    );
  }

  // ============================================================
  // AI TARGET
  // ============================================================

  void setTarget(Vector2 target, double speed) {
    _target = target;
    _speed = speed;
  }

  // ============================================================
  // STOP
  // ============================================================

  void stopMoving() {
    _target = null;
    _speed = 0;
  }

  Vector2? get target => _target;

  // ============================================================
  // BATH
  // ============================================================

  void onBath() {
    currentIntent = BirdAreaIntent.pond;
    ai.forceState(
      BirdState.flying,
      target: Vector2(GameConstants.pondX, GameConstants.pondY),
      speed: GameConstants.birdFlySpeed,
      duration: 15.0,
    );
  }
}
