import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../../../core/constants/constants.dart';
import '../mental_health_game.dart';
import '../controllers/bird_ai_controller.dart';
import 'pond_component.dart';
import 'tree_component.dart';

class BirdComponent extends SpriteAnimationComponent
    with
        CollisionCallbacks,
        DragCallbacks,
        HasGameReference<MentalHealthGame> {
  Vector2? _target;
  double _speed = 0;

  late BirdAIController ai;

  bool _isDragging = false;

  BirdComponent() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // ----------------------------------------------------------
    // BIRD HITBOX
    // ----------------------------------------------------------
    //
    // Don't use the entire mental_health image as collision area.
    // Keep the hitbox smaller so the mental_health doesn't hit trees
    // when its transparent/outer sprite area touches them.
    //

    add(
      RectangleHitbox(
        size: Vector2(
          size.x * 0.45,
          size.y * 0.45,
        ),
        position: Vector2(
          size.x * 0.275,
          size.y * 0.30,
        ),
      ),
    );

    // ----------------------------------------------------------
    // AI
    // ----------------------------------------------------------

    ai = BirdAIController(this);

    add(ai);

    // ----------------------------------------------------------
    // ANIMATION
    // ----------------------------------------------------------

    await _loadAnimations();
  }

  // ============================================================
  // ANIMATION
  // ============================================================

  Future<void> _loadAnimations() async {
    final image = await game.images.load(
      'mental_healths/flying.png',
    );

    const columns = 3;
    const rows = 3;

    final frameWidth =
        image.width / columns;

    final frameHeight =
        image.height / rows;

    final frames =
    <SpriteAnimationFrameData>[];

    for (int row = 0; row < rows; row++) {
      for (int column = 0;
      column < columns;
      column++) {
        frames.add(
          SpriteAnimationFrameData(
            srcPosition: Vector2(
              column * frameWidth,
              row * frameHeight,
            ),
            srcSize: Vector2(
              frameWidth,
              frameHeight,
            ),
            stepTime: 1 / 10,
          ),
        );
      }
    }

    animation =
        SpriteAnimation.fromFrameData(
          image,
          SpriteAnimationData(frames),
        );
  }

  // ============================================================
  // DRAG START
  // ============================================================

  @override
  void onDragStart(
      DragStartEvent event,
      ) {
    super.onDragStart(event);

    _isDragging = true;

    // Stop automatic movement.
    stopMoving();

    // Stop current AI state.
    ai.forceState(
      BirdState.idle,
    );
  }

  // ============================================================
  // DRAG UPDATE
  // ============================================================

  @override
  void onDragUpdate(
      DragUpdateEvent event,
      ) {
    super.onDragUpdate(event);

    if (!_isDragging) {
      return;
    }

    // IMPORTANT:
    //
    // Use canvasDelta instead of localDelta.
    //
    // This works correctly with camera zoom.
    //

    position += event.canvasDelta;

    _keepInsideWorld();
  }

  // ============================================================
  // DRAG END
  // ============================================================

  @override
  void onDragEnd(
      DragEndEvent event,
      ) {
    super.onDragEnd(event);

    _isDragging = false;

    stopMoving();

    // MentalHealth stays where the user dropped it.
  }

  // ============================================================
  // DRAG CANCEL
  // ============================================================

  @override
  void onDragCancel(
      DragCancelEvent event,
      ) {
    super.onDragCancel(event);

    _isDragging = false;

    stopMoving();
  }

  // ============================================================
  // COLLISION
  // ============================================================

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(
      intersectionPoints,
      other,
    );

    // ----------------------------------------------------------
    // POND
    // ----------------------------------------------------------

    if (other is PondComponent) {
      if (ai.currentState == BirdState.flying ||
          ai.currentState == BirdState.walking) {
        stopMoving();

        ai.forceState(
          BirdState.bathing,
          duration: 5.0,
        );
      }

      return;
    }

    // ----------------------------------------------------------
    // TREE
    // ----------------------------------------------------------

    if (other is TreeComponent) {
      _handleTreeCollision(other);

      return;
    }
  }

  // ============================================================
  // TREE COLLISION
  // ============================================================

  void _handleTreeCollision(
      TreeComponent tree,
      ) {
    // Stop the mental_health immediately.
    stopMoving();

    // ----------------------------------------------------------
    // PUSH BIRD AWAY FROM TREE
    // ----------------------------------------------------------

    final Vector2 difference =
        position - tree.position;

    if (difference.length > 0) {
      final Vector2 pushDirection =
      difference.normalized();

      position += pushDirection * 15;
    }

    // Keep mental_health inside world.
    _keepInsideWorld();

    // ----------------------------------------------------------
    // TELL AI TO STOP
    // ----------------------------------------------------------

    ai.forceState(
      BirdState.idle,
    );
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    // User is controlling the mental_health.
    if (_isDragging) {
      return;
    }

    // ----------------------------------------------------------
    // AI MOVEMENT
    // ----------------------------------------------------------

    if (_target != null) {
      final Vector2 direction =
      (_target! - position).normalized();

      final double distance =
      position.distanceTo(_target!);

      if (distance < 5) {
        _target = null;
        _speed = 0;
      } else {
        position +=
            direction * _speed * dt;
      }
    }

    _keepInsideWorld();
  }

  // ============================================================
  // KEEP BIRD INSIDE WORLD
  // ============================================================

  void _keepInsideWorld() {
    final double halfWidth =
        size.x / 2;

    final double halfHeight =
        size.y / 2;

    position.x = position.x.clamp(
      halfWidth,
      GameConstants.worldWidth -
          halfWidth,
    );

    position.y = position.y.clamp(
      halfHeight,
      GameConstants.worldHeight -
          halfHeight,
    );
  }

  // ============================================================
  // AI TARGET
  // ============================================================

  void setTarget(
      Vector2 target,
      double speed,
      ) {
    if (_isDragging) {
      return;
    }

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
  // FEED
  // ============================================================

  void onFeed() {
    stopMoving();

    ai.forceState(
      BirdState.eating,
      duration: 3.0,
    );
  }

  // ============================================================
  // BATH
  // ============================================================

  void onBath() {
    if (_isDragging) {
      return;
    }

    ai.forceState(
      BirdState.flying,
      target: Vector2(
        GameConstants.pondX,
        GameConstants.pondY,
      ),
      speed: GameConstants.mental_healthFlySpeed,
      duration: 10.0,
    );
  }
}