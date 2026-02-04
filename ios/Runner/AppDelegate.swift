import UIKit
import Flutter
import Firebase
// Remove this line
// import flutter_downloader

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    // Remove these lines
    // FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// Remove this entire function
// private func registerPlugins(registry: FlutterPluginRegistry) {
//     if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
//        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
//     }
// }