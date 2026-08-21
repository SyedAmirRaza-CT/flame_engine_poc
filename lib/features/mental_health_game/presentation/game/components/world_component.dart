import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/constants.dart';
import 'tree_component.dart';

class WorldComponent extends PositionComponent {
  final List<Vector2> _treePositions = [];
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    size = Vector2(
      GameConstants.worldWidth,
      GameConstants.worldHeight,
    );

    _generateTrees();

    for (final position in _treePositions) {
      add(
        TreeComponent(
          position: position,
          size: Vector2(
            GameConstants.treeSize,
            GameConstants.treeSize,
          ),
        ),
      );
    }
  }

  void _generateTrees() {
    _treePositions.clear();
    int attempts = 0;

    while (_treePositions.length < GameConstants.treeCount && attempts < 1000) {
      attempts++;
      final position = Vector2(
        _random.nextDouble() * size.x,
        _random.nextDouble() * size.y,
      );

      // Check distance to other trees
      bool tooClose = false;
      for (final existing in _treePositions) {
        if (position.distanceTo(existing) < GameConstants.treeSpacing) {
          tooClose = true;
          break;
        }
      }

      if (tooClose) continue;

      // Check distance to pond
      if (_isNearPond(position)) continue;

      // Keep inside world with some padding
      const double padding = 100;
      if (position.x < padding || position.x > size.x - padding ||
          position.y < padding || position.y > size.y - padding) {
        continue;
      }

      _treePositions.add(position);
    }
  }

  bool _isNearPond(Vector2 position) {
    final pondCenter = Vector2(
      GameConstants.pondX,
      GameConstants.pondY,
    );

    final dx = (position.x - pondCenter.x).abs();
    final dy = (position.y - pondCenter.y).abs();

    final pondHalfWidth = GameConstants.pondWidth / 2;
    final pondHalfHeight = GameConstants.pondHeight / 2;

    return dx < pondHalfWidth + GameConstants.treePadding &&
        dy < pondHalfHeight + GameConstants.treePadding;
  }

  @override
  void render(Canvas canvas) {
    // Fill the world with a nice grass color
    final grassPaint = Paint()..color = Colors.green.shade200;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      grassPaint,
    );
  }
}
