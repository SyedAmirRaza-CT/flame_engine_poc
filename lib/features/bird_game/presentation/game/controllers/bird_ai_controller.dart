import 'dart:math';

import 'package:flame/components.dart';

import '../../../../../core/constants/constants.dart';
import '../components/bird_component.dart';
import '../components/seed_component.dart';

enum BirdState { idle, walking, flying, bathing, eating, sleeping }

class BirdAIController extends Component {
  final BirdComponent bird;

  BirdState currentState = BirdState.idle;

  double _stateTimer = 0;

  final Random _random = Random();

  BirdAIController(this.bird);

  @override
  void update(double dt) {
    super.update(dt);

    _stateTimer -= dt;

    if (_stateTimer <= 0) {
      _chooseNextState();
    }

    _executeState(dt);
  }

  void _chooseNextState() {
    final roll = _random.nextDouble();

    if (roll < 0.4) {
      // IDLE
      currentState = BirdState.idle;

      _stateTimer = 2.0 + _random.nextDouble() * 3.0;

      bird.stopMoving();
    } else if (roll < 0.7) {
      // WALKING
      currentState = BirdState.walking;

      _stateTimer = 3.0 + _random.nextDouble() * 4.0;

      _setRandomTarget(GameConstants.birdWalkSpeed);
    } else {
      // FLYING
      currentState = BirdState.flying;

      _stateTimer = 4.0 + _random.nextDouble() * 5.0;

      _setRandomTarget(GameConstants.birdFlySpeed);
    }
  }

  void _setRandomTarget(double speed) {
    final target = Vector2(
      _random.nextDouble() * GameConstants.worldWidth,
      _random.nextDouble() * GameConstants.worldHeight,
    );

    bird.setTarget(target, speed);
  }

  void _executeState(double dt) {
    if (currentState == BirdState.eating) {
      _handleEating();
    }
  }

  void _handleEating() {
    final game = bird.game;

    // No seeds available.
    if (game.seeds.isEmpty) {
      if (_stateTimer <= 0) {
        _chooseNextState();
      }

      return;
    }

    // Find closest seed.
    SeedComponent? closestSeed;
    double closestDistance = double.infinity;

    for (final seed in game.seeds) {
      final distance = seed.position.distanceTo(bird.position);

      if (distance < closestDistance) {
        closestDistance = distance;
        closestSeed = seed;
      }
    }

    if (closestSeed == null) {
      return;
    }

    // Bird reached seed.
    if (closestDistance < 15) {
      bird.stopMoving();

      game.removeSeed(closestSeed);

      // Peck/eating time.
      _stateTimer = 1.0;

      return;
    }

    // Move toward seed.
    final target = bird.target;

    if (target == null || target.distanceTo(closestSeed.position) > 5) {
      bird.setTarget(closestSeed.position, GameConstants.birdWalkSpeed);
    }
  }

  void onSeedPlaced(Vector2 position) {
    currentState = BirdState.eating;

    _stateTimer = 20.0;

    bird.stopMoving();
  }

  void forceState(
    BirdState state, {
    Vector2? target,
    double? speed,
    double duration = 5.0,
  }) {
    currentState = state;

    _stateTimer = duration;

    if (target != null) {
      bird.setTarget(target, speed ?? GameConstants.birdWalkSpeed);
    } else {
      bird.stopMoving();
    }
  }
}
