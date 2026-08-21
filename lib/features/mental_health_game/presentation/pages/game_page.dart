import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/mental_health_game.dart';
import '../controllers/bird_controller.dart';
import '../widgets/bird_stats_widget.dart';
import '../widgets/game_ui_overlay.dart';

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
    
    // Load mental_health profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BirdController>().loadMentalHealth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game, autofocus: true),
          
          // UI Components
          const SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: BirdStatsWidget(),
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: GameUIOverlay(game: _game),
          ),

          Consumer<BirdController>(
            builder: (context, controller, child) {
              if (controller.mental_healthProfile == null) {
                return _NameEntryOverlay(
                  onSubmitted: (name) {
                    controller.createMentalHealth(name);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _NameEntryOverlay extends StatefulWidget {
  final Function(String) onSubmitted;

  const _NameEntryOverlay({required this.onSubmitted});

  @override
  State<_NameEntryOverlay> createState() => _NameEntryOverlayState();
}

class _NameEntryOverlayState extends State<_NameEntryOverlay> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "What's your mental_health's name?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Enter name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    widget.onSubmitted(_controller.text);
                  }
                },
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
