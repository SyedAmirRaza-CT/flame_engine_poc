import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';

class GameUtils {
  /// Renders a collision hitbox on the given [canvas] using the provided [path].
  static void drawDebugHitbox(Canvas canvas, Path path, {Color color = Colors.red}) {
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, strokePaint);
  }

  /// Loads a [SpriteAnimation] from a PNG or SVG asset.
  static Future<SpriteAnimation> loadSpriteAnimation(
    FlameGame game,
    String path, {
    required int columns,
    required int rows,
    required double stepTime,
    int? amount,
    Vector2? svgTargetSize,
  }) async {
    final bool isSvg = path.toLowerCase().endsWith('.svg');
    ui.Image image;
    double width, height;

    if (isSvg) {
      final svg = await game.loadSvg(path);
      final targetSize = svgTargetSize ?? Vector2(1000, 1000);
      width = targetSize.x;
      height = targetSize.y;
      
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      svg.render(canvas, targetSize);
      image = await recorder.endRecording().toImage(width.toInt(), height.toInt());
    } else {
      image = await game.images.load(path);
      width = image.width.toDouble();
      height = image.height.toDouble();
    }

    final frameWidth = width / columns;
    final frameHeight = height / rows;

    final frames = <SpriteAnimationFrameData>[];
    int count = 0;
    final int totalFrames = amount ?? (columns * rows);

    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        if (count >= totalFrames) break;
        frames.add(
          SpriteAnimationFrameData(
            srcPosition: Vector2(column * frameWidth, row * frameHeight),
            srcSize: Vector2(frameWidth, frameHeight),
            stepTime: stepTime,
          ),
        );
        count++;
      }
      if (count >= totalFrames) break;
    }

    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData(frames),
    );
  }
}
