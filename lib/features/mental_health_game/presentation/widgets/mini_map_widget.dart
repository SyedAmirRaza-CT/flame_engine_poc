import 'dart:async' as async;
import 'package:flutter/material.dart';
import 'package:mental_health_game/features/mental_health_game/presentation/game/components/pond_component.dart';
import 'package:mental_health_game/features/mental_health_game/presentation/game/components/world_component.dart';
import 'package:provider/provider.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../../../../core/constants/constants.dart';
import '../game/mental_health_game.dart';
import '../game/components/bird_component.dart';
import '../providers/mental_health_provider.dart';

class MiniMapWidget extends StatefulWidget {
  final MentalHealthGame game;
  final double size;

  const MiniMapWidget({
    super.key,
    required this.game,
    this.size = 150.0,
  });

  @override
  State<MiniMapWidget> createState() => _MiniMapWidgetState();
}

class _MiniMapWidgetState extends State<MiniMapWidget> {
  late async.Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Refresh the mini-map frequently to show bird/camera movement
    _refreshTimer = async.Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onPanUpdate: (details) => _handleInteraction(details.localPosition),
          onTapDown: (details) => _handleInteraction(details.localPosition),
          child: CustomPaint(
            painter: _MiniMapPainter(
              game: widget.game,
              currentBackground: context.watch<MentalHealthProvider>().currentBackground,
            ),
          ),
        ),
      ),
    );
  }

  void _handleInteraction(Offset localPosition) {
    // Convert mini-map coordinates back to world coordinates
    final double scale = GameConstants.worldWidth / widget.size;
    final double worldX = localPosition.dx * scale;
    final double worldY = localPosition.dy * scale;

    // Move camera (viewfinder position is the center)
    widget.game.camera.viewfinder.position = Vector2(worldX, worldY);
    // Ensure clamping is applied
    widget.game.forceCameraClamping();
  }
}

class _MiniMapPainter extends CustomPainter {
  final MentalHealthGame game;
  final String currentBackground;

  _MiniMapPainter({required this.game, required this.currentBackground});

  @override
  void paint(Canvas canvas, Size size) {
    if (!game.isLoaded) return;

    // Safely check if components are available
    final bird = game.world.children.whereType<BirdComponent>().firstOrNull;
    final park = game.world.children.whereType<WorldComponent>().firstOrNull;
    final pond = game.world.children.whereType<PondComponent>().firstOrNull;

    if (bird == null || park == null || pond == null) return;

    final double scale = size.width / GameConstants.worldWidth;

    // 1. Draw Actual Background Image (Miniaturized)
    final backgroundSprite = park.backgroundSprite;
    if (backgroundSprite != null) {
      backgroundSprite.render(canvas, size: Vector2(size.width, size.height));
    } else {
      final backgroundPaint = Paint()..color = Colors.green.shade200;
      canvas.drawRect(Offset.zero & size, backgroundPaint);
    }

    // 2. Draw Interactive Areas (Using actual component positions for accuracy)
    
    // Pond
    final pondPaint = Paint()..color = Colors.blue.withValues(alpha: 0.6);
    // Use pond.position which is the top-left, so we calculate center for drawCircle
    final pondPos = Offset(
      (pond.position.x + pond.size.x / 2) * scale,
      (pond.position.y + pond.size.y / 2) * scale,
    );
    canvas.drawCircle(pondPos, (pond.size.x / 2) * scale, pondPaint);

    // 3. Draw Bird (Small dot)
    final birdPaint = Paint()..color = Colors.white;
    final birdPos = Offset(bird.position.x * scale, bird.position.y * scale);
    
    canvas.drawCircle(birdPos, 5, Paint()..color = Colors.black26);
    canvas.drawCircle(birdPos, 3.5, birdPaint);
    canvas.drawCircle(birdPos, 2, Paint()..color = Colors.blueAccent);

    // 4. Draw Viewport Rectangle (Visual representation of camera)
    final viewfinder = game.camera.viewfinder;
    final zoom = viewfinder.zoom;
    
    final double worldVisibleWidth = game.size.x / zoom;
    final double worldVisibleHeight = game.size.y / zoom;

    final double rectWidth = worldVisibleWidth * scale;
    final double rectHeight = worldVisibleHeight * scale;

    final double rectX = (viewfinder.position.x - worldVisibleWidth / 2) * scale;
    final double rectY = (viewfinder.position.y - worldVisibleHeight / 2) * scale;

    final viewportPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(
      Rect.fromLTWH(rectX, rectY, rectWidth, rectHeight),
      viewportPaint,
    );
    
    // Add subtle corner indicators to viewport
    final cornerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(rectX, rectY), 2, cornerPaint);
    canvas.drawCircle(Offset(rectX + rectWidth, rectY + rectHeight), 2, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter oldDelegate) {
    return true; // We listen to viewfinder changes via ListenableBuilder
  }
}
