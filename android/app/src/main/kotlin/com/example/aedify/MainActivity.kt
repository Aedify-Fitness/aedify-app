package com.example.aedify

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var progressVideo: ProgressVideoMetadata? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        progressVideo = ProgressVideoMetadata(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
    }
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        progressVideo?.dispose()
        progressVideo = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
