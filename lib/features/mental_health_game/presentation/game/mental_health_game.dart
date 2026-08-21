import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors;

import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../providers/mental_health_provider.dart';
import 'components/world_component.dart';
import 'components/pond_component.dart';
import 'components/bird_component.dart';
import 'controllers/bird_ai_controller.dart';

class MentalHealthGame extends FlameGame
    with
        ScrollDetector,
        ScaleDetector,
        TapCallbacks,
        DoubleTapCallbacks,
        HasCollisionDetection {
  
  late WorldComponent park;
  late PondComponent pond;
  late BirdComponent bird;

  // ==========================================================
  // CAMERA CONSTANTS
  // ==========================================================

  double get minZoom {
    // Return a very small value initially so we don't block low zoom settings
    if (size.x == 0 || size.y == 0) return 0.001;
    
    // Calculate zoom needed to fill screen
    final double zoomX = size.x / GameConstants.worldWidth;
    final double zoomY = size.y / GameConstants.worldHeight;
    return (zoomX > zoomY ? zoomX : zoomY).clamp(0.001, GameConstants.maxZoom);
  }

  double get maxZoom => GameConstants.maxZoom;
  double get initialZoom => GameConstants.initialZoom;

  @override
  Color backgroundColor() => Colors.green[200]!;

  // ==========================================================
  // LOAD
  // ==========================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 2. World Environment
    park = WorldComponent();
    await world.add(park);
    
    // Set initial background
    await changeBackground('environment/background/day.png');

    // 3. Pond
    pond = PondComponent();
    await world.add(pond);


    // 5. The Bird
    bird = BirdComponent(key: ComponentKey.named('bird'))
      ..position = Vector2(
        (GameConstants.worldWidth / 2 )- 150,
        (GameConstants.worldHeight / 2) + 150,
      )
      ..size = Vector2(400, 400);
    await world.add(bird);

    // 5. Camera Initial Setup
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = bird.position;
    camera.viewfinder.zoom = initialZoom;

    _keepCameraInsideWorld();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Sync Flame's built-in debugMode with our provider
    final showDebug = buildContext?.read<MentalHealthProvider>().showDebugHitboxes ?? false;
    if (debugMode != showDebug) {
      debugMode = showDebug;
      // Also propagate to all children that might need it
      propagateDebugMode(showDebug);
    }
  }

  void propagateDebugMode(bool enabled) {
    for (final component in world.children) {
      component.debugMode = enabled;
    }
  }

  // ==========================================================
  // INPUT HANDLERS
  // ==========================================================

  @override
  void onTapDown(TapDownEvent event) {
    // Single tap seed placement removed as requested.
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    final worldPosition = camera.viewfinder.parentToLocal(event.localPosition);
    
    // Command the bird to fly to the double-tapped location
    bird.ai.forceState(
      BirdState.flying,
      target: worldPosition,
      speed: GameConstants.birdFlySpeed,
      duration: 10.0,
    );
  }

  double _startZoom = 0.1;

  @override
  void onScaleStart(ScaleStartInfo info) {
    _startZoom = camera.viewfinder.zoom;
    // Stop following the bird so manual pan can work
    camera.stop();
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    // Panning
    final double currentZoom = camera.viewfinder.zoom;
    final Vector2 delta = info.delta.global / currentZoom;
    camera.viewfinder.position -= delta;

    // Zooming
    final double scale = info.scale.global.x;
    if (scale != 1.0) {
      camera.viewfinder.zoom = (_startZoom * scale).clamp(minZoom, maxZoom);
    }
    
    _keepCameraInsideWorld();
  }

  @override
  void onScroll(PointerScrollInfo info) {
    final double currentZoom = camera.viewfinder.zoom;
    final double newZoom = currentZoom - (info.scrollDelta.global.y * 0.001);
    camera.viewfinder.zoom = newZoom.clamp(minZoom, maxZoom).toDouble();
    _keepCameraInsideWorld();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isMounted) {
      _keepCameraInsideWorld();
    }
  }

  // ==========================================================
  // ACTIONS (Called from UI)
  // ==========================================================

  void bathBird() {
    bird.onBath();
  }

  Future<void> changeBackground(String path) async {
    await park.updateBackground(path);
  }

  void forceCameraClamping() {
    _keepCameraInsideWorld();
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  void _keepCameraInsideWorld() {
    if (!isMounted) return;

    final double zoom = camera.viewfinder.zoom;
    
    // The logical width and height of the world visible on the screen
    final double visibleWidth = size.x / zoom;
    final double visibleHeight = size.y / zoom;

    // We clamp the viewfinder position (center of the screen)
    // to ensure the visible edges don't go past 0 or worldWidth/worldHeight.
    
    final double minX = visibleWidth / 2;
    final double maxX = GameConstants.worldWidth - (visibleWidth / 2);
    
    final double minY = visibleHeight / 2;
    final double maxY = GameConstants.worldHeight - (visibleHeight / 2);

    // Initial position
    double targetX = camera.viewfinder.position.x;
    double targetY = camera.viewfinder.position.y;

    if (visibleWidth >= GameConstants.worldWidth) {
      targetX = GameConstants.worldWidth / 2;
    } else {
      targetX = targetX.clamp(minX, maxX);
    }

    if (visibleHeight >= GameConstants.worldHeight) {
      targetY = GameConstants.worldHeight / 2;
    } else {
      targetY = targetY.clamp(minY, maxY);
    }
    
    camera.viewfinder.position = Vector2(targetX, targetY);
  }
}
