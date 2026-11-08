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
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "org.humanhealthos.paths") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "org.humanhealthos/paths", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      if call.method == "appDataDir" {
        // R004: the app's folder is created here and kept out of iCloud and
        // computer backups; if that cannot be ensured, no folder is given
        // and the app keeps data in memory only.
        guard
          let base = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
          ).first
        else {
          result(nil)
          return
        }
        var dir = base.appendingPathComponent("HumanHealthOS", isDirectory: true)
        do {
          try FileManager.default.createDirectory(
            at: dir, withIntermediateDirectories: true)
          var values = URLResourceValues()
          values.isExcludedFromBackup = true
          try dir.setResourceValues(values)
          result(base.path)
        } catch {
          result(nil)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
