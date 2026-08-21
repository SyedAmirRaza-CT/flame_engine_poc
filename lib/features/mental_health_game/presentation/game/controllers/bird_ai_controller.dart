import 'dart:math';

import 'package:flame/components.dart';

import '../../../../../core/constants/constants.dart';
import '../components/bird_component.dart';
import '../components/seed_component.dart';

enum BirdState { idle, walking, flying, bathing, eating, sleeping }

class BirdAIController extends Component {
  final BirdComponent mental_health;

  BirdState currentState = BirdState.idle;

  double _stateTimer = 0;

  final Random _random = Random();

  BirdAIController(this.mental_health);

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

      mental_health.stopMoving();
    } else if (roll < 0.7) {
      // WALKING
      currentState = BirdState.walking;

      _stateTimer = 3.0 + _random.nextDouble() * 4.0;

      _setRandomTarget(GameConstants.mental_healthWalkSpeed);
    } else {
      // FLYING
      currentState = BirdState.flying;

      _stateTimer = 4.0 + _random.nextDouble() * 5.0;

      _setRandomTarget(GameConstants.mental_healthFlySpeed);
    }
  }

  void _setRandomTarget(double speed) {
    final target = Vector2(
      _random.nextDouble() * GameConstants.worldWidth,
      _random.nextDouble() * GameConstants.worldHeight,
    );

    mental_health.setTarget(target, speed);
  }

  void _executeState(double dt) {
    if (currentState == BirdState.eating) {
      _handleEating();
    }
  }

  void _handleEating() {
    final game = mental_health.game;

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
      final distance = seed.position.distanceTo(mental_health.position);

      if (distance < closestDistance) {
        closestDistance = distance;
        closestSeed = seed;
      }
    }

    if (closestSeed == null) {
      return;
    }

    // MentalHealth reached seed.
    if (closestDistance < 15) {
      mental_health.stopMoving();

      game.removeSeed(closestSeed);

      // Peck/eating time.
      _stateTimer = 1.0;

      return;
    }

    // Move toward seed.
    final target = mental_health.target;

    if (target == null || target.distanceTo(closestSeed.position) > 5) {
      mental_health.setTarget(closestSeed.position, GameConstants.mental_healthWalkSpeed);
    }
  }

  void onSeedPlaced(Vector2 position) {
    currentState = BirdState.eating;

    _stateTimer = 20.0;

    mental_health.stopMoving();
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
      mental_health.setTarget(target, speed ?? GameConstants.mental_healthWalkSpeed);
    } else {
      mental_health.stopMoving();
    }
  }
}
