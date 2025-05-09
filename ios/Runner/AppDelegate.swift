import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Hata yakalama ekleyelim
    do {
      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    } catch {
      print("Critical error during app launch: \(error)")
      // Hata durumunda bile uygulamayı devam ettirmeye çalışalım
      return true
    }
  }
}
