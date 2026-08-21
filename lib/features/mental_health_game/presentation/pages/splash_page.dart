import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bird_provider.dart';
import 'game_page.dart';
import 'name_entry_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    // 1. Give it a moment for the splash visual
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 2. Load the bird profile
    final birdProvider = context.read<BirdProvider>();
    await birdProvider.loadBird();

    if (!mounted) return;

    // 3. Decide where to go
    if (birdProvider.birdProfile == null) {
      // First launch -> Name Entry
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NameEntryPage()),
      );
    } else {
      // Existing user -> Game
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GamePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flutter_dash, // Dash icon for the bird
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              "Mental Health Game",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              color: Colors.green.shade700,
            ),
          ],
        ),
      ),
    );
  }
}
