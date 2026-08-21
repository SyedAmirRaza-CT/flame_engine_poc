import 'dart:math';

import 'package:flame/components.dart';
import 'package:mental_health_game/features/mental_health_game/presentation/game/components/pond_component.dart';

import '../../../../../core/constants/constants.dart';
import '../components/bird_component.dart';

enum BirdState { idle, walking, bathing, sleeping }

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
    chooseNewSafeTarget();
  }

  void chooseNewSafeTarget() {
    final roll = _random.nextDouble();

    // Favor walking (0.85 chance) to keep the world feeling alive
    if (roll < 0.15) {
      // IDLE
      currentState = BirdState.idle;
      _stateTimer = 2.0 + _random.nextDouble() * 2.0;
      bird.stopMoving();
    } else {
      // WALKING
      currentState = BirdState.walking;
      // Walk for longer distances
      _stateTimer = 8.0 + _random.nextDouble() * 10.0;
      _setSafeTarget();
    }
  }

  void _setSafeTarget() {
    Vector2 target;
    int attempts = 0;
    
    do {
      // Pick a target within the ground boundaries
      final x = GameConstants.groundSidePadding + 
               _random.nextDouble() * (GameConstants.worldWidth - 2 * GameConstants.groundSidePadding);
      final y = GameConstants.groundTopY + 
               _random.nextDouble() * (GameConstants.groundBottomY - GameConstants.groundTopY);
      
      target = Vector2(x, y);
      attempts++;
    } while (_isInsidePond(target) && attempts < 15);

    bird.setTarget(target, GameConstants.birdWalkSpeed);
  }

  bool _isInsidePond(Vector2 position) {
    final pondCenter = Vector2(GameConstants.pondX, GameConstants.pondY);
    
    // The pond is an oval shape, so we should check both width and height 
    // to ensure the whole footprint is avoided.
    final double dx = (position.x - pondCenter.x).abs();
    final double dy = (position.y - pondCenter.y).abs();
    
    // Avoid the area with a safety buffer
    const double buffer = 150.0;
    return dx < (GameConstants.pondWidth / 2) + buffer && 
           dy < (GameConstants.pondHeight / 2) + buffer;
  }

  void _executeState(double dt) {
    if (currentState == BirdState.walking && bird.currentIntent == BirdAreaIntent.pond) {
      final pond = bird.game.world.children.whereType<PondComponent>().firstOrNull;
      if (pond != null) {
        final distanceToCenter = bird.position.distanceTo(pond.position);
        if (distanceToCenter < 15) {
          // Reached the middle!
          bird.stopMoving();
          bird.currentIntent = BirdAreaIntent.none;
          forceState(BirdState.bathing, duration: 10.0);
        }
      }
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
