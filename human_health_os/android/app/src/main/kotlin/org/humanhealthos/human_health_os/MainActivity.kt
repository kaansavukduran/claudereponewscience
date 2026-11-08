package org.humanhealthos.human_health_os

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// M001: tells the app its private folder (Context.filesDir), which other apps
// cannot read and Android removes with the app. No plugin dependency.
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "org.humanhealthos/paths")
            .setMethodCallHandler { call, result ->
                if (call.method == "appDataDir") {
                    result.success(filesDir.absolutePath)
                } else {
                    result.notImplemented()
                }
            }
    }
}
