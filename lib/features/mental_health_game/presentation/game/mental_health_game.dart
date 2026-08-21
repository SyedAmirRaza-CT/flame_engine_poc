import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors;

import '../../../../core/constants/constants.dart';
import 'components/world_component.dart';
import 'components/pond_component.dart';
import 'components/seed_component.dart';

class MentalHealthGame extends FlameGame
    with
        ScrollDetector,
        ScaleDetector,
        TapCallbacks {
  late WorldComponent park;
  late PondComponent pond;
  
  // Stubs for broken references in other files
  final List<SeedComponent> seeds = [];
  dynamic mental_health; // Stub for BirdAIController reference

  // ==========================================================
  // CAMERA
  // ==========================================================

  static const double minZoom = 0.5;
  static const double maxZoom = 4.0;

  // ==========================================================
  // BACKGROUND
  // ==========================================================

  @override
  Color backgroundColor() => Colors.green[200]!;

  // ==========================================================
  // LOAD
  // ==========================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ========================================================
    // WORLD
    // ========================================================

    park = WorldComponent();

    await world.add(park);

    // ========================================================
    // POND
    // ========================================================

    pond = PondComponent();

    await world.add(pond);

    // ========================================================
    // CAMERA SETUP
    // ========================================================

    camera.viewfinder.anchor = Anchor.center;
    
    // Initial position at center of the world
    camera.viewfinder.position = Vector2(
      GameConstants.worldWidth / 2,
      GameConstants.worldHeight / 2,
    );

    camera.viewfinder.zoom = 1.0;

    _keepCameraInsideWorld();
  }

  // Stubs for broken references in other files
  void removeSeed(SeedComponent seed) {}
  void feedMentalHealth() {}
  void bathMentalHealth() {}

  // ==========================================================
  // SCALE / PINCH / PAN (FLAME ScaleDetector)
  // ==========================================================

  double _startZoom = 1.0;

  @override
  void onScaleStart(ScaleStartInfo info) {
    _startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    // 1. PANNING
    final double currentZoom = camera.viewfinder.zoom;
    final Vector2 delta = info.delta.global / currentZoom;
    camera.viewfinder.position -= delta;

    // 2. ZOOMING (Pinch)
    // info.scale.global.x or y can be used as they are usually same for pinch
    final double scale = info.scale.global.x;
    if (scale != 1.0) {
      camera.viewfinder.zoom = (_startZoom * scale).clamp(minZoom, maxZoom);
    }
    
    _keepCameraInsideWorld();
  }

  // ==========================================================
  // MOUSE / TRACKPAD ZOOM
  // ==========================================================

  @override
  void onScroll(PointerScrollInfo info) {
    final double currentZoom = camera.viewfinder.zoom;
    final double newZoom = currentZoom - (info.scrollDelta.global.y * 0.001);

    camera.viewfinder.zoom = newZoom.clamp(minZoom, maxZoom).toDouble();

    _keepCameraInsideWorld();
  }

  // ==========================================================
  // RESIZE
  // ==========================================================

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isMounted) {
      _keepCameraInsideWorld();
    }
  }

  // ==========================================================
  // KEEP CAMERA INSIDE WORLD
  // ==========================================================

  void _keepCameraInsideWorld() {
    if (!isMounted) return;

    final double zoom = camera.viewfinder.zoom;
    final double visibleWidth = size.x / zoom;
    final double visibleHeight = size.y / zoom;

    // Horizontal clamping
    if (visibleWidth >= GameConstants.worldWidth) {
      camera.viewfinder.position.x = GameConstants.worldWidth / 2;
    } else {
      final double halfWidth = visibleWidth / 2;
      camera.viewfinder.position.x = camera.viewfinder.position.x.clamp(
        halfWidth,
        GameConstants.worldWidth - halfWidth,
      );
    }

    // Vertical clamping
    if (visibleHeight >= GameConstants.worldHeight) {
      camera.viewfinder.position.y = GameConstants.worldHeight / 2;
    } else {
      final double halfHeight = visibleHeight / 2;
      camera.viewfinder.position.y = camera.viewfinder.position.y.clamp(
        halfHeight,
        GameConstants.worldHeight - halfHeight,
      );
    }
  }
}
