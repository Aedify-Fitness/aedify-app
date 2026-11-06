package com.example.aedify

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    private val analyticsExport = AnalyticsCsvExport(this)
    private var progressVideo: ProgressVideoMetadata? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        analyticsExport.attach(flutterEngine.dartExecutor.binaryMessenger)
        progressVideo = ProgressVideoMetadata(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
    }
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        analyticsExport.close()
        progressVideo?.dispose()
        progressVideo = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
