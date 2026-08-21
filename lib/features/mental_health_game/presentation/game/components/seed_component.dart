import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SeedComponent extends PositionComponent with HasGameReference {
  SeedComponent({required Vector2 position}) : super(position: position, size: Vector2.all(10), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.yellow[800]!;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
  }
}
