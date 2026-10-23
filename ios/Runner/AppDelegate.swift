import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // Exposes the raw iOS push-registration outcome to Dart. The Firebase
    // plugin only NSLog()s registration failures, so without this channel
    // the failure reason is invisible from Dart and from Firestore.
    let channel = FlutterMethodChannel(
      name: "roasted/apns",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "getRegistrationState" {
        let defaults = UserDefaults.standard
        result([
          "error": defaults.string(forKey: "apnsRegistrationError") ?? NSNull(),
          "hasToken": defaults.string(forKey: "apnsDeviceToken") != nil,
        ])
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // Always forward to super so FlutterAppDelegate still delivers these
  // callbacks to the Firebase plugin.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    UserDefaults.standard.set(
      deviceToken.map { String(format: "%02x", $0) }.joined(),
      forKey: "apnsDeviceToken")
    UserDefaults.standard.removeObject(forKey: "apnsRegistrationError")
    super.application(
      application,
      didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    UserDefaults.standard.set(
      error.localizedDescription, forKey: "apnsRegistrationError")
    UserDefaults.standard.removeObject(forKey: "apnsDeviceToken")
    super.application(
      application,
      didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
