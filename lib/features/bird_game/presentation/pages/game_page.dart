import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/bird_game.dart';
import '../providers/bird_providers.dart';
import '../widgets/bird_stats_widget.dart';
import '../widgets/game_ui_overlay.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  late BirdGame _game;

  @override
  void initState() {
    super.initState();
    _game = BirdGame();
    
    // Load bird profile
    Future.microtask(() => ref.read(birdControllerProvider.notifier).loadBird());
  }

  @override
  Widget build(BuildContext context) {
    final bird = ref.watch(birdControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          
          // // UI Components
          // const SafeArea(
          //   child: Align(
          //     alignment: Alignment.topLeft,
          //     child: BirdStatsWidget(),
          //   ),
          // ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: GameUIOverlay(game: _game),
          ),

          if (bird == null)
            _NameEntryOverlay(
              onSubmitted: (name) {
                ref.read(birdControllerProvider.notifier).createBird(name);
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
                "What's your bird's name?",
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
