import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../core/utils/game_utils.dart';
import '../../providers/mental_health_provider.dart';
import '../mental_health_game.dart';

class PondComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<MentalHealthGame> {
  PondComponent() {
    // Center it exactly at GameConstants.pondX, GameConstants.pondY
    position = Vector2(
      GameConstants.pondX,
      GameConstants.pondY,
    );

    size = Vector2(
      GameConstants.pondWidth,
      GameConstants.pondHeight,
    );
    
    anchor = Anchor.center;
  }

  // ==========================================================
  // COLLISION POLYGON (Relative to Center)
  // ==========================================================

  List<Vector2> get _collisionPoints => [
    Vector2(-0.35, -0.05), // Adjusted to be relative to center (-0.5 to 0.5)
    Vector2(-0.25, -0.30),
    Vector2(0.00, -0.42),
    Vector2(0.28, -0.35),
    Vector2(0.45, -0.12),
    Vector2(0.38, 0.18),
    Vector2(0.18, 0.38),
    Vector2(-0.10, 0.44),
    Vector2(-0.35, 0.28),
    Vector2(-0.45, 0.08),
  ];

  // ==========================================================
  // HITBOX
  // ==========================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Since anchor is center, we use PolygonHitbox.relative with points 
    // centered around (0,0)
    add(
      PolygonHitbox.relative(
        _collisionPoints,
        parentSize: size,
      ),
    );
  }

  // ==========================================================
  // COLLISION PATH (For Debug Rendering)
  // ==========================================================

  Path _collisionPath() {
    final points = _collisionPoints;
    final path = Path();
    if (points.isEmpty) return path;

    // Shift points from -0.5..0.5 range to 0.0..1.0 range for drawing relative to component top-left
    // Or just draw relative to center if preferred. Flame renders from top-left (0,0) of the component.
    final double midX = size.x / 2;
    final double midY = size.y / 2;

    path.moveTo(
      midX + points.first.x * size.x,
      midY + points.first.y * size.y,
    );

    for (int i = 1; i < points.length; i++) {
      path.lineTo(
        midX + points[i].x * size.x,
        midY + points[i].y * size.y,
      );
    }

    path.close();
    return path;
  }

  // ==========================================================
  // POND PATH
  // ==========================================================

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

  // ==========================================================
  // RENDER
  // ==========================================================

  @override
  void render(Canvas canvas) {
    final pondPath = _pondPath();

    // ========================================================
    // SHORE
    // ========================================================

    final shorePaint = Paint()
      ..color = Colors.brown.shade400
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      pondPath,
      shorePaint,
    );

    // ========================================================
    // WATER
    // ========================================================

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

    // ========================================================
    // WATER HIGHLIGHT
    // ========================================================

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.25,
      )
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

    // ========================================================
    // HITBOX DEBUG (Toggleable via Utility)
    // ========================================================

    final showDebug = game.buildContext?.read<MentalHealthProvider>().showDebugHitboxes ?? false;
    
    if (showDebug) {
      GameUtils.drawDebugHitbox(canvas, _collisionPath());
    }
  }
}
