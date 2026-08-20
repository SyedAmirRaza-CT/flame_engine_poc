import 'dart:math';
import 'package:flame/components.dart';
import '../../../../../core/constants/constants.dart';
import '../components/bird_component.dart';
import '../components/seed_component.dart';

enum BirdState {
  idle,
  walking,
  flying,
  bathing,
  eating,
  sleeping
}

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
      currentState = BirdState.idle;
      _stateTimer = 2.0 + _random.nextDouble() * 3.0;
      bird.stopMoving();
    } else if (roll < 0.7) {
      currentState = BirdState.walking;
      _stateTimer = 3.0 + _random.nextDouble() * 4.0;
      _setRandomTarget(GameConstants.birdWalkSpeed);
    } else {
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
      final game = bird.game;
      if (game.seeds.isNotEmpty) {
        // Find closest seed
        SeedComponent? closest;
        double minDist = double.infinity;
        for (final seed in game.seeds) {
          final d = seed.position.distanceTo(bird.position);
          if (d < minDist) {
            minDist = d;
            closest = seed;
          }
        }

        if (closest != null) {
          if (minDist < 15) {
            // Eat the seed
            game.removeSeed(closest);
            _stateTimer = 1.0; // Pecking time
          } else if (bird.target == null || bird.target!.distanceTo(closest.position) > 5) {
            // Move to the closest seed
            bird.setTarget(closest.position, GameConstants.birdFlySpeed);
          }
        }
      } else if (_stateTimer <= 0) {
        // No more seeds, go back to normal
        _chooseNextState();
      }
    }
  }

  void onSeedPlaced(Vector2 position) {
    // If a seed is placed, the bird notices and starts looking for seeds
    if (currentState != BirdState.eating) {
      currentState = BirdState.eating;
      _stateTimer = 20.0; // Total time allowance to eat all seeds
    }
  }

  void forceState(BirdState state, {Vector2? target, double? speed, double duration = 5.0}) {
    currentState = state;
    _stateTimer = duration;
    if (target != null) {
      bird.setTarget(target, speed ?? GameConstants.birdWalkSpeed);
    }
  }
}
