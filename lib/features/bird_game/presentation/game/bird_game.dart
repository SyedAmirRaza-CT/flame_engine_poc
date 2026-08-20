import 'dart:math';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart' show Colors;
import '../../../../core/constants/constants.dart';
import 'components/world_component.dart';
import 'components/bird_component.dart';
import 'components/pond_component.dart';
import 'components/seed_component.dart';

class BirdGame extends FlameGame with PanDetector, ScrollDetector, HasCollisionDetection, TapCallbacks {
  late BirdComponent bird;
  late WorldComponent park;
  late PondComponent pond;
  final List<SeedComponent> seeds = [];

  @override
  Color backgroundColor() => Colors.green[200]!;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    park = WorldComponent();
    await world.add(park);

    pond = PondComponent()
      ..position = Vector2(GameConstants.pondX, GameConstants.pondY)
      ..size = Vector2.all(GameConstants.pondRadius * 2)
      ..anchor = Anchor.center;
    await world.add(pond);

    bird = BirdComponent()
      ..position = Vector2(GameConstants.worldWidth / 2, GameConstants.worldHeight / 2)
      ..size = Vector2(180, 180);
    await world.add(bird);

    camera.follow(bird);
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, GameConstants.worldWidth, GameConstants.worldHeight),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    final worldPosition = camera.viewfinder.parentToLocal(event.localPosition);
    _placeSeed(worldPosition);
  }

  void _placeSeed(Vector2 position) {
    final seed = SeedComponent(position: position);
    seeds.add(seed);
    world.add(seed);
    bird.ai.onSeedPlaced(position);
  }

  void removeSeed(SeedComponent seed) {
    seeds.remove(seed);
    seed.removeFromParent();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    camera.stop();
    camera.viewfinder.position -= info.delta.global / camera.viewfinder.zoom;
  }

  @override
  void onScroll(PointerScrollInfo info) {
    double zoom = camera.viewfinder.zoom;
    zoom -= info.scrollDelta.global.y * 0.001;
    camera.viewfinder.zoom = zoom.clamp(0.5, 2.0);
  }

  void feedBird() {
    final random = Random();
    final center = bird.position + Vector2(
      (random.nextDouble() - 0.5) * 400,
      (random.nextDouble() - 0.5) * 400,
    );
    
    for (int i = 0; i < 5; i++) {
      final offset = Vector2(
        (random.nextDouble() - 0.5) * 100,
        (random.nextDouble() - 0.5) * 100,
      );
      final pos = center + offset;

      // Manual clamp to ensure seeds stay in world
      final clampedPos = Vector2(
        pos.x.clamp(0, GameConstants.worldWidth),
        pos.y.clamp(0, GameConstants.worldHeight),
      );

      _placeSeed(clampedPos);
    }
  }

  void bathBird() {
    bird.onBath();
  }
}
