import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/chooser_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tutorial_screen.dart';
import 'screens/finger_selection_screen.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    final prefs = await SharedPreferences.getInstance();
    runApp(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(prefs),
        child: const ChooserApp(),
      ),
    );
  } catch (e) {
    // Shared Preferences başlatılamazsa varsayılan değerlerle devam et
    print('SharedPreferences error: $e');
    // Geçici bir SharedPreferences nesnesi kullanarak devam et
    runApp(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(null),
        child: const ChooserApp(),
      ),
    );
  }
}

class ChooserApp extends StatelessWidget {
  const ChooserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chooser',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          background: Colors.black,
          primary: Colors.white,
          secondary: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const FingerSelectionScreen(),
    );
  }
} 