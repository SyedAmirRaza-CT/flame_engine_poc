import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/constants.dart';

class WorldComponent extends PositionComponent {
  Sprite? treeSprite;
  final List<Vector2> _treePositions = [];
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    size = Vector2(GameConstants.worldWidth, GameConstants.worldHeight);
    treeSprite = await Sprite.load('environment/tree.png');
    
    // Generate many random tree positions
    for (int i = 0; i < 40; i++) {
      _treePositions.add(Vector2(
        _random.nextDouble() * size.x,
        _random.nextDouble() * size.y,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    // Fill the entire world with grass color first
    final paint = Paint()..color = Colors.green[200]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

    if (treeSprite != null) {
      for (final pos in _treePositions) {
        // Avoid pond area
        if (pos.distanceTo(Vector2(GameConstants.pondX, GameConstants.pondY)) > GameConstants.pondRadius + 50) {
          treeSprite!.render(canvas, position: pos, size: Vector2(80, 80), anchor: Anchor.center);
        }
      }
    } else {
      // Fallback
      final treePaint = Paint()..color = Colors.green[800]!;
      for (final pos in _treePositions) {
        canvas.drawCircle(Offset(pos.x, pos.y), 30, treePaint);
      }
    }
  }
}
