import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'screens/chooser_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tutorial_screen.dart';
import 'screens/finger_selection_screen.dart';
import 'providers/settings_provider.dart';

// Tüm hataları yakalamak için global bir error handler tanımlayalım
void main() async {
  // Hata yakalama için stream controller
  FlutterError.onError = (FlutterErrorDetails details) {
    print('Flutter error caught: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };
  
  // Platformdan gelen hataları yakalamak için
  PlatformDispatcher.instance.onError = (error, stack) {
    print('Platform error caught: $error');
    print('Stack trace: $stack');
    return true; // Hata işlendi olarak kabul et
  };
  
  // Ana uygulamayı try-catch içinde başlat
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      runApp(
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(prefs),
          child: const ChooserApp(),
        ),
      );
    } catch (e, stack) {
      // Shared Preferences başlatılamazsa varsayılan değerlerle devam et
      print('SharedPreferences error: $e');
      print('Stack trace: $stack');
      // Geçici bir SharedPreferences nesnesi kullanarak devam et
      runApp(
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(null),
          child: const ChooserApp(),
        ),
      );
    }
  }, (error, stack) {
    print('Uncaught error in app: $error');
    print('Stack trace: $stack');
  });
}

class ChooserApp extends StatelessWidget {
  const ChooserApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Error widget'ı özelleştirelim
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Text(
            'Bir hata oluştu',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    };
    
    return MaterialApp(
      title: 'Chooser',
      // Hata ayıklama banner'ını kaldıralım
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          background: Colors.black,
          primary: Colors.white,
          secondary: Colors.blue,
        ),
        useMaterial3: true,
      ),
      // İlk ekranı daha basit tutalım, potansiyel hataları azaltmak için
      home: Builder(
        builder: (context) {
          try {
            // Karmaşık ekran yerine geçici olarak basit bir ekran kullanıyoruz
            return Scaffold(
              appBar: AppBar(
                title: const Text('Chooser'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Uygulama Başlatıldı!', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Bu butona tıklandığında asıl ekrana geçeceğiz
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FingerSelectionScreen(),
                          ),
                        );
                      },
                      child: const Text('İleri'),
                    ),
                  ],
                ),
              ),
            );
          } catch (e) {
            // Eğer ana ekran yüklenemezse, basit bir hata ekranı göster
            return Scaffold(
              body: Center(
                child: Text('Uygulama yüklenirken bir hata oluştu'),
              ),
            );
          }
        },
      ),
    );
  }
} 