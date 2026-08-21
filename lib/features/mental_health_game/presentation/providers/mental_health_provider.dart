import 'package:flutter/foundation.dart';

class MentalHealthProvider extends ChangeNotifier {
  String _currentBackground = 'environment/background/park.png';
  bool _showDebugHitboxes = false;

  String get currentBackground => _currentBackground;
  bool get showDebugHitboxes => _showDebugHitboxes;

  void setBackground(String path) {
    if (_currentBackground == path) return;
    _currentBackground = path;
    notifyListeners();
  }

  void toggleDebugHitboxes() {
    _showDebugHitboxes = !_showDebugHitboxes;
    notifyListeners();
  }
}
