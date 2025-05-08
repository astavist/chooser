import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _hasSeenTutorialKey = 'has_seen_tutorial';

  SettingsProvider(this._prefs);

  bool get hasSeenTutorial => _prefs.getBool(_hasSeenTutorialKey) ?? false;

  Future<void> setHasSeenTutorial(bool value) async {
    await _prefs.setBool(_hasSeenTutorialKey, value);
    notifyListeners();
  }
} 