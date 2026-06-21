import 'package:flutter/foundation.dart';

/// Tracks cinematic splash completion for overlay / entrance timing.
class WelcomeAnimationGate extends ChangeNotifier {
  bool _splashComplete = false;

  bool get splashComplete => _splashComplete;

  void markSplashComplete() {
    if (_splashComplete) return;
    _splashComplete = true;
    notifyListeners();
  }
}
