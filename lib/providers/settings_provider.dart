import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  final SharedPreferences? _prefs;
  static const String _hasSeenTutorialKey = 'has_seen_tutorial';

  SettingsProvider(this._prefs);

  bool get hasSeenTutorial {
    try {
      return _prefs?.getBool(_hasSeenTutorialKey) ?? false;
    } catch (e) {
      print('Error reading SharedPreferences: $e');
      return false;
    }
  }

  Future<void> setHasSeenTutorial(bool value) async {
    try {
      await _prefs?.setBool(_hasSeenTutorialKey, value);
      notifyListeners();
    } catch (e) {
      print('Error writing to SharedPreferences: $e');
    }
  }
} 