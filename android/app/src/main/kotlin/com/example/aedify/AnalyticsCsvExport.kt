package com.example.aedify

import android.os.Handler
import android.os.Looper
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** Explicit system-document export. No paths or platform errors cross the channel. */
class AnalyticsCsvExport(private val activity: FlutterFragmentActivity) {
    private var pending: MethodChannel.Result? = null
    private var bytes: ByteArray? = null
    private var writing = false
    private var selecting = false
    private var channel: MethodChannel? = null
    private val main = Handler(Looper.getMainLooper())
    private val launcher = activity.registerForActivityResult(
        ActivityResultContracts.CreateDocument("text/csv")
    ) { uri ->
        selecting = false
        val payload = bytes
        if (uri == null || payload == null) {
            finish(false)
        } else {
            writing = true
            Thread {
                var success = false
                try {
                    activity.contentResolver.openOutputStream(uri, "wt")!!.use { it.write(payload) }
                    success = true
                } catch (_: Exception) {
                    try { activity.contentResolver.delete(uri, null, null) } catch (_: Exception) {}
                }
                main.post {
                    writing = false
                    if (success) finish(true) else fail()
                }
            }.start()
        }
    }

    fun attach(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, "aedify/analytics_export")
        channel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "save" -> {
                    val payload = call.argument<ByteArray>("bytes")
                    if (pending != null || selecting || writing || payload == null || payload.isEmpty() || payload.size > 8388608) {
                        result.error("unavailable", null, null)
                    } else {
                        pending = result
                        bytes = payload
                        selecting = true
                        try { launcher.launch("aedify_analytics.csv") } catch (_: Exception) { selecting = false; fail() }
                    }
                }
                "cancel" -> {
                    if (!writing) finish(false)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun finish(saved: Boolean) {
        val result = pending
        pending = null
        bytes = null
        result?.success(saved)
    }
    private fun fail() {
        val result = pending
        pending = null
        bytes = null
        result?.error("unavailable", null, null)
    }
    fun close() {
        finish(false)
        channel?.setMethodCallHandler(null)
        channel = null
    }
}
