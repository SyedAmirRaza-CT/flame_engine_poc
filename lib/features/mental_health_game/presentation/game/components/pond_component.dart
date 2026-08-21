import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/constants.dart';

class PondComponent extends PositionComponent with CollisionCallbacks {
  PondComponent() {
    position = Vector2(
      GameConstants.pondX - GameConstants.pondWidth / 2,
      GameConstants.pondY - GameConstants.pondHeight / 2,
    );

    size = Vector2(
      GameConstants.pondWidth,
      GameConstants.pondHeight,
    );
  }

  @override
  Future<void> onLoad() async {
    add(
      PolygonHitbox(
        [
          Vector2(0.15, 0.45),
          Vector2(0.25, 0.20),
          Vector2(0.50, 0.08),
          Vector2(0.78, 0.15),
          Vector2(0.95, 0.38),
          Vector2(0.88, 0.68),
          Vector2(0.68, 0.88),
          Vector2(0.40, 0.94),
          Vector2(0.15, 0.78),
          Vector2(0.05, 0.58),
        ],
      ),
    );
  }

  Path _pondPath() {
    return Path()
      ..moveTo(
        size.x * 0.15,
        size.y * 0.45,
      )
      ..quadraticBezierTo(
        size.x * 0.05,
        size.y * 0.28,
        size.x * 0.25,
        size.y * 0.20,
      )
      ..quadraticBezierTo(
        size.x * 0.48,
        size.y * 0.02,
        size.x * 0.72,
        size.y * 0.15,
      )
      ..quadraticBezierTo(
        size.x * 0.98,
        size.y * 0.28,
        size.x * 0.88,
        size.y * 0.52,
      )
      ..quadraticBezierTo(
        size.x * 0.82,
        size.y * 0.78,
        size.x * 0.58,
        size.y * 0.88,
      )
      ..quadraticBezierTo(
        size.x * 0.30,
        size.y * 0.98,
        size.x * 0.12,
        size.y * 0.72,
      )
      ..quadraticBezierTo(
        size.x * 0.02,
        size.y * 0.55,
        size.x * 0.15,
        size.y * 0.45,
      )
      ..close();
  }

  @override
  void render(Canvas canvas) {
    final pondPath = _pondPath();

    // Shore
    final shorePaint = Paint()
      ..color = Colors.brown.shade400
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      pondPath,
      shorePaint,
    );

    // Water - slightly smaller than shore
    canvas.save();

    canvas.translate(
      size.x * 0.03,
      size.y * 0.03,
    );

    final waterPath = _pondPath();

    final waterPaint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      waterPath,
      waterPaint,
    );

    canvas.restore();

    // Water highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final highlightPath = Path()
      ..moveTo(
        size.x * 0.25,
        size.y * 0.35,
      )
      ..quadraticBezierTo(
        size.x * 0.40,
        size.y * 0.20,
        size.x * 0.58,
        size.y * 0.25,
      )
      ..quadraticBezierTo(
        size.x * 0.70,
        size.y * 0.28,
        size.x * 0.75,
        size.y * 0.38,
      );

    canvas.drawPath(
      highlightPath,
      highlightPaint,
    );
  }
}