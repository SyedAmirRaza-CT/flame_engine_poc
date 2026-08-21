import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/constants.dart';

class WorldComponent extends PositionComponent {
  Sprite? _backgroundSprite;
  String? _currentBackgroundPath;

  Sprite? get backgroundSprite => _backgroundSprite;

  @override
  Future<void> onLoad() async {
    size = Vector2(
      GameConstants.worldWidth,
      GameConstants.worldHeight,
    );
  }

  Future<void> updateBackground(String path) async {
    if (_currentBackgroundPath == path) return;
    _currentBackgroundPath = path;
    _backgroundSprite = await Sprite.load(path);
  }

  @override
  void render(Canvas canvas) {
    if (_backgroundSprite != null) {
      _backgroundSprite!.render(canvas, size: size);
    } else {
      // Fill the world with a nice grass color if sprite is loading/missing
      final grassPaint = Paint()..color = Colors.green.shade200;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        grassPaint,
      );
    }
  }
}
