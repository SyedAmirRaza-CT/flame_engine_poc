import 'package:flutter/material.dart';

class GameUtils {
  /// Renders a collision hitbox on the given [canvas] using the provided [path].
  /// This is intended for debugging purposes.
  static void drawDebugHitbox(Canvas canvas, Path path, {Color color = Colors.red}) {
    // Semi-transparent fill
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Thick outline
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, strokePaint);

    // Draw small circles at vertices to show points clearly
    // This is optional but helps see the polygon structure
  }
}
