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
    // M001: the app's private Application Support folder (inside its
    // sandbox), so entries and display choices survive a restart.
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "HumanOsPaths") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "org.humanhealthos/paths", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      if call.method == "appDataDir" {
        let url = FileManager.default.urls(
          for: .applicationSupportDirectory, in: .userDomainMask
        ).first
        result(url?.path)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
