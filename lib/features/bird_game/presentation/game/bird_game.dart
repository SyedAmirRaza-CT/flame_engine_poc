import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors;

import '../../../../core/constants/constants.dart';
import 'components/bird_component.dart';
import 'components/pond_component.dart';
import 'components/seed_component.dart';
import 'components/world_component.dart';

class BirdGame extends FlameGame
    with
        ScaleDetector,
        PanDetector,
        ScrollDetector,
        HasCollisionDetection,
        TapCallbacks {
  late BirdComponent bird;
  late WorldComponent park;
  late PondComponent pond;

  final List<SeedComponent> seeds = [];

  // ==========================================================
  // CAMERA / ZOOM
  // ==========================================================

  static const double minZoom = 0.7;
  static const double maxZoom = 3.0;

  double _zoomAtScaleStart = 1.0;

  // ==========================================================
  // CAMERA CONTROL
  // ==========================================================

  bool _cameraFollowingBird = true;

  // ==========================================================
  // BACKGROUND
  // ==========================================================

  @override
  Color backgroundColor() => Colors.green[200]!;

  // ==========================================================
  // GAME RESIZE
  // ==========================================================

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (!isMounted) {
      return;
    }

    _updateCameraZoomForScreen(size);
  }

  void _updateCameraZoomForScreen(Vector2 screenSize) {
    // We want the initial game to comfortably fit
    // on iPad / mobile screens.
    //
    // The world can be larger than the screen.
    //
    // Camera zoom determines how much of the world
    // is visible.

    final scaleX =
        screenSize.x / GameConstants.worldWidth;

    final scaleY =
        screenSize.y / GameConstants.worldHeight;

    final initialZoom =
        min(scaleX, scaleY) * 1.15;

    camera.viewfinder.zoom =
        initialZoom.clamp(
          minZoom,
          maxZoom,
        );
  }

  // ==========================================================
  // LOAD
  // ==========================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ========================================================
    // PARK / WORLD
    // ========================================================

    park = WorldComponent();

    await world.add(park);

    // ========================================================
    // POND
    // ========================================================

    pond = PondComponent()
      ..position = Vector2(
        GameConstants.pondX,
        GameConstants.pondY,
      )
      ..size = Vector2(
        GameConstants.pondWidth,
        GameConstants.pondHeight,
      )
      ..anchor = Anchor.center;

    await world.add(pond);

    // ========================================================
    // BIRD
    // ========================================================

    bird = BirdComponent()
      ..position = Vector2(
        GameConstants.worldWidth / 2,
        GameConstants.worldHeight / 2,
      )
      ..size = Vector2(
        180,
        180,
      );

    await world.add(bird);

    // ========================================================
    // CAMERA
    // ========================================================

    camera.viewfinder.anchor = Anchor.center;

    // Start camera at bird.
    camera.viewfinder.position = bird.position;

    // Follow bird continuously.
    _startFollowingBird();

    // Initial zoom.
    camera.viewfinder.zoom = 1.0;
  }

  // ==========================================================
  // FOLLOW BIRD
  // ==========================================================

  void _startFollowingBird() {
    _cameraFollowingBird = true;

    camera.follow(
      bird,
      maxSpeed: double.infinity,
    );
  }

  // ==========================================================
  // STOP FOLLOWING
  // ==========================================================

  void _stopFollowingBird() {
    _cameraFollowingBird = false;

    camera.stop();
  }

  // ==========================================================
  // PAN
  // ==========================================================

  @override
  void onPanStart(DragStartInfo info) {
    // If the user manually moves the camera,
    // temporarily stop following the bird.

    _stopFollowingBird();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    camera.viewfinder.position -=
        info.delta.global / camera.viewfinder.zoom;

    _keepCameraInsideWorld();
  }

  @override
  void onPanEnd(DragEndInfo info) {
    // After manual camera movement,
    // return camera to the bird.

    _startFollowingBird();
  }

  // ==========================================================
  // KEEP CAMERA INSIDE WORLD
  // ==========================================================

  void _keepCameraInsideWorld() {
    final visibleWorldSize =
        size / camera.viewfinder.zoom;

    final halfWidth =
        visibleWorldSize.x / 2;

    final halfHeight =
        visibleWorldSize.y / 2;

    camera.viewfinder.position.x =
        camera.viewfinder.position.x.clamp(
          halfWidth,
          GameConstants.worldWidth - halfWidth,
        );

    camera.viewfinder.position.y =
        camera.viewfinder.position.y.clamp(
          halfHeight,
          GameConstants.worldHeight - halfHeight,
        );
  }

  // ==========================================================
  // TAP
  // ==========================================================

  @override
  void onTapDown(TapDownEvent event) {
    final Vector2 worldPosition =
    camera.viewfinder.parentToLocal(
      event.localPosition,
    );

    _placeSeed(worldPosition);
  }

  // ==========================================================
  // PLACE SEED
  // ==========================================================

  void _placeSeed(Vector2 position) {
    final Vector2 safePosition = Vector2(
      position.x.clamp(
        0,
        GameConstants.worldWidth,
      ).toDouble(),
      position.y.clamp(
        0,
        GameConstants.worldHeight,
      ).toDouble(),
    );

    final seed = SeedComponent(
      position: safePosition,
    );

    seeds.add(seed);

    world.add(seed);

    bird.ai.onSeedPlaced(safePosition);
  }

  // ==========================================================
  // REMOVE SEED
  // ==========================================================

  void removeSeed(SeedComponent seed) {
    seeds.remove(seed);

    seed.removeFromParent();
  }

  // ==========================================================
  // PINCH START
  // ==========================================================

  @override
  void onScaleStart(ScaleStartInfo info) {
    _zoomAtScaleStart =
        camera.viewfinder.zoom;
  }

  // ==========================================================
  // PINCH UPDATE
  // ==========================================================

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final double scale =
        info.scale.global.x;

    if (scale <= 0) {
      return;
    }

    final double newZoom =
    (_zoomAtScaleStart * scale)
        .clamp(
      minZoom,
      maxZoom,
    )
        .toDouble();

    camera.viewfinder.zoom = newZoom;

    _keepCameraInsideWorld();
  }

  // ==========================================================
  // SCROLL / MOUSE ZOOM
  // ==========================================================

  @override
  void onScroll(PointerScrollInfo info) {
    final double currentZoom =
        camera.viewfinder.zoom;

    final double newZoom =
        currentZoom -
            (info.scrollDelta.global.y * 0.01);

    camera.viewfinder.zoom =
        newZoom.clamp(
          minZoom,
          maxZoom,
        ).toDouble();

    _keepCameraInsideWorld();
  }

  // ==========================================================
  // FEED BIRD
  // ==========================================================

  void feedBird() {
    final random = Random();

    final Vector2 center =
        bird.position +
            Vector2(
              (random.nextDouble() - 0.5) * 400,
              (random.nextDouble() - 0.5) * 400,
            );

    for (int i = 0; i < 5; i++) {
      final Vector2 offset = Vector2(
        (random.nextDouble() - 0.5) * 100,
        (random.nextDouble() - 0.5) * 100,
      );

      final Vector2 position =
          center + offset;

      final Vector2 clampedPosition =
      Vector2(
        position.x
            .clamp(
          0,
          GameConstants.worldWidth,
        )
            .toDouble(),
        position.y
            .clamp(
          0,
          GameConstants.worldHeight,
        )
            .toDouble(),
      );

      _placeSeed(clampedPosition);
    }
  }

  // ==========================================================
  // BATH BIRD
  // ==========================================================

  void bathBird() {
    bird.onBath();
  }
}