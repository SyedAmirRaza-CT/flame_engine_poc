import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../core/utils/game_utils.dart';
import 'package:mental_health_game/features/mental_health_game/domain/entities/bird_profile.dart';
import 'package:mental_health_game/features/mental_health_game/presentation/providers/bird_provider.dart';

import '../mental_health_game.dart';
import '../controllers/bird_ai_controller.dart';
import 'pond_component.dart';
import 'bird_status_component.dart';
import 'bird_clothing_component.dart';

enum BirdAreaIntent { none, pond, call }

class BirdComponent extends SpriteAnimationGroupComponent<BirdState>
    with CollisionCallbacks, HasGameReference<MentalHealthGame> {
  Vector2? _target;
  double _speed = 0;

  late BirdAIController ai;
  BirdProfile? currentProfile;

  // The intent with which the bird is moving.
  BirdAreaIntent currentIntent = BirdAreaIntent.none;

  // Smoother movement state
  final Vector2 _velocity = Vector2.zero();

  BirdComponent({super.key}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // ----------------------------------------------------------
    // BIRD HITBOX
    // ----------------------------------------------------------
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
    // STATUS & CLOTHING
    // ----------------------------------------------------------
    add(BirdStatusComponent(this));
    add(BirdClothingComponent(this));

    // ----------------------------------------------------------
    // ANIMATIONS (Future-Ready Group)
    // ----------------------------------------------------------
    animations = await _loadAllAnimations();
    current = BirdState.idle;
  }

  Future<Map<BirdState, SpriteAnimation>> _loadAllAnimations() async {
    final Map<BirdState, SpriteAnimation> anims = {};

    // 1. Walking Animation (PNG)
    anims[BirdState.walking] = await GameUtils.loadSpriteAnimation(
      game,
      'birds/bird_walking.png',
      columns: 3,
      rows: 3,
      stepTime: 1 / 10,
    );
    anims[BirdState.idle] = anims[BirdState.walking]!;

    // 2. Bathing Animation (SVG)
    // The SVG has a viewBox of 3708x1266, which contains 6 frames in a 3x2 grid.
    anims[BirdState.bathing] = await GameUtils.loadSpriteAnimation(
      game,
      'images/birds/bird_bathing.svg',
      columns: 4,
      rows: 2,
      stepTime: 0.15,
      amount: 6,
      svgTargetSize: Vector2(3708, 1266),
    );

    // Placeholder for Sleeping, etc.
    anims[BirdState.sleeping] = anims[BirdState.idle]!; 

    return anims;
  }

  // ============================================================
  // COLLISION
  // ============================================================

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    // 1. Priority: Handle special area interactions (Pond)
    if (other is PondComponent && (currentIntent == BirdAreaIntent.pond || ai.currentState == BirdState.bathing)) {
      super.onCollisionStart(intersectionPoints, other);
      return;
    }

    // 2. Ignore our own status/clothing components
    if (other is BirdStatusComponent || other is BirdClothingComponent) {
      super.onCollisionStart(intersectionPoints, other);
      return;
    }

    // 3. Generic "Bounce" for ALL other collisions
    super.onCollisionStart(intersectionPoints, other);
    final bounceSource = intersectionPoints.isNotEmpty ? intersectionPoints.first : other.absoluteCenter;
    _avoidArea(bounceSource);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is BirdStatusComponent || other is BirdClothingComponent) return;
    if (other is PondComponent && (currentIntent == BirdAreaIntent.pond || ai.currentState == BirdState.bathing)) return;

    final pushSource = intersectionPoints.isNotEmpty ? intersectionPoints.first : other.absoluteCenter;
    _avoidArea(pushSource, isContinuous: true);
  }

  void _avoidArea(Vector2 obstaclePosition, {bool isContinuous = false}) {
    final Vector2 pushDirection = (position - obstaclePosition).normalized();
    final double repulsionForce = isContinuous ? 400.0 : 800.0;
    _velocity.add(pushDirection * repulsionForce * 0.1); 

    if (currentIntent != BirdAreaIntent.none) {
      if (_target != null) {
        final Vector2 toTarget = (_target! - position).normalized();
        Vector2 perpendicular = Vector2(-pushDirection.y, pushDirection.x);
        
        if (perpendicular.dot(toTarget) < 0) {
          perpendicular = -perpendicular;
        }
        
        _velocity.add(perpendicular * 300.0 * 0.1);
        _target = _target! + (perpendicular * 50);
      }
    } else if (!isContinuous) {
      stopMoving();
      ai.chooseNewSafeTarget();
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

    // Sync animation state with AI
    // Only update if the state has actually changed to avoid resetting the animation ticker
    if (current != ai.currentState && animations!.containsKey(ai.currentState)) {
      current = ai.currentState;

      // ----------------------------------------------------------
      // DYNAMIC RESIZING
      // ----------------------------------------------------------
      // The bathing SVG is much larger/wider than the walking PNG.
      // We shrink it so it looks natural in the pond.
      if (current == BirdState.bathing) {
        size = Vector2(250, 250);
      } else {
        size = Vector2(400, 400);
      }
    }

    // ----------------------------------------------------------
    // MOVEMENT & STEERING
    // ----------------------------------------------------------
    if (_target != null) {
      final double distance = position.distanceTo(_target!);

      // If we are close enough to the target, stop moving
      if (distance < 15) {
        stopMoving();
        // If this was a user call, reset intent so AI can resume random wandering
        if (currentIntent == BirdAreaIntent.call) {
          currentIntent = BirdAreaIntent.none;
          // Stay for 5 seconds after reaching the called location
          ai.forceState(BirdState.idle, duration: 5.0);
        }
      } else {
        final Vector2 desired = (_target! - position).normalized() * _speed;
        final Vector2 steering = desired - _velocity;
        _velocity.add(steering * 5.0 * dt);
        
        if (_velocity.length > _speed) {
          _velocity.scaleTo(_speed);
        }
      }
    } else {
      _velocity.scale(1.0 - (10.0 * dt));
      if (_velocity.length < 1) _velocity.setZero();
    }

    position += _velocity * dt;
    _keepInsideWorld();
  }

  void _keepInsideWorld() {
    final double halfWidth = size.x / 2;
    final double halfHeight = size.y / 2;

    // Use ground constraints from GameConstants
    final double minX = GameConstants.groundSidePadding + halfWidth;
    final double maxX = GameConstants.worldWidth - GameConstants.groundSidePadding - halfWidth;
    
    final double minY = GameConstants.groundTopY + halfHeight;
    final double maxY = GameConstants.groundBottomY - halfHeight;

    position.x = position.x.clamp(minX, maxX);
    position.y = position.y.clamp(minY, maxY);
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

  void onBath() {
    currentIntent = BirdAreaIntent.pond;
    ai.forceState(
      BirdState.walking,
      target: Vector2(GameConstants.pondX, GameConstants.pondY),
      speed: GameConstants.birdWalkSpeed,
      duration: 15.0,
    );
  }
}
