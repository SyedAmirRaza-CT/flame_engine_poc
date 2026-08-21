import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/mental_health_game.dart';
import '../widgets/bird_stats_widget.dart';
import '../widgets/game_options_bottom_sheet.dart';
import '../widgets/mini_map_widget.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late MentalHealthGame _game;

  @override
  void initState() {
    super.initState();
    _game = MentalHealthGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game, autofocus: true),
          
          // UI Components (Stats in top-left)
          const SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: BirdStatsWidget(),
            ),
          ),

          // Mini Map (Top-right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: MiniMapWidget(game: _game),
            ),
          ),

          // Menu Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.small(
              onPressed: () => GameOptionsBottomSheet.show(context, _game),
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              child: const Icon(Icons.menu, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
