import 'dart:math';

import 'package:flame/components.dart';

import '../../../../../core/constants/constants.dart';
import '../components/bird_component.dart';

enum BirdState { idle, walking, flying, bathing,}

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
    // Only choose random behaviors if there is no specific intent from the player
    if (bird.currentIntent != BirdAreaIntent.none) {
      return; 
    }
    chooseNewRandomTarget();
  }

  void chooseNewRandomTarget() {
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
    if (currentState == BirdState.flying) {

    }
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
