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

    while (
    _treePositions.length <
        GameConstants.treeCount &&
        attempts < 1000) {
      attempts++;

      final position = Vector2(
        _random.nextDouble() * size.x,
        _random.nextDouble() * size.y,
      );

      if (_isNearPond(position)) {
        continue;
      }

      if (_isTooCloseToAnotherTree(position)) {
        continue;
      }

      if (!_isInsideWorld(position)) {
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

    final dx =
    (position.x - pondCenter.x).abs();

    final dy =
    (position.y - pondCenter.y).abs();

    final pondHalfWidth =
        GameConstants.pondWidth / 2;

    final pondHalfHeight =
        GameConstants.pondHeight / 2;

    return dx <
        pondHalfWidth +
            GameConstants.treePadding &&
        dy <
            pondHalfHeight +
                GameConstants.treePadding;
  }

  bool _isTooCloseToAnotherTree(
      Vector2 position,
      ) {
    for (final existingPosition
    in _treePositions) {
      if (position.distanceTo(
        existingPosition,
      ) <
          GameConstants.treeSpacing) {
        return true;
      }
    }

    return false;
  }

  bool _isInsideWorld(
      Vector2 position,
      ) {
    const double padding = 60;

    return position.x > padding &&
        position.x <
            size.x - padding &&
        position.y > padding &&
        position.y <
            size.y - padding;
  }

  @override
  void render(Canvas canvas) {
    final grassPaint = Paint()
      ..color = Colors.green.shade200;

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.x,
        size.y,
      ),
      grassPaint,
    );
  }
}