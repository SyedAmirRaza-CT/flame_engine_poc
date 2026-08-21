import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../controllers/bird_ai_controller.dart';
import 'bird_component.dart';

class BirdStatusComponent extends PositionComponent with HasGameReference {
  final BirdComponent bird;

  BirdStatusComponent(this.bird) : super(anchor: Anchor.bottomCenter);

  @override
  void update(double dt) {
    super.update(dt);
    // Position it slightly above the bird
    position = Vector2(bird.size.x / 2, -10);
  }

  @override
  void render(Canvas canvas) {
    // We'll use the game's buildContext to get the current bird profile from Provider
    final context = game.buildContext;
    if (context == null) return;

    // We can't easily use Provider here because it's in the render loop.
    // Instead, let's have the BirdAIController or BirdComponent keep track of the current status flags
    // and just render them here.
    
    final List<String> symbols = [];
    
    // For now, let's use the ai state as well
    final state = bird.ai.currentState;
    
    // Check AI states for immediate feedback
    if (state == BirdState.bathing) symbols.add('💧');
    
    // We will ask the bird component to provide the current profile stats
    final profile = bird.currentProfile;
    if (profile != null) {
      if (profile.hunger > 70) symbols.add('🍕');
      if (profile.happiness > 80) symbols.add('❤️');
      if (profile.energy < 30) symbols.add('😴');
      if (profile.cleanliness < 40) symbols.add('🧼');
    }

    if (symbols.isEmpty) return;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    double offsetX = 0;
    for (final symbol in symbols) {
      textPainter.text = TextSpan(
        text: symbol,
        style: const TextStyle(fontSize: 24),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(offsetX - (symbols.length * 12), 0));
      offsetX += 24;
    }
  }
}
