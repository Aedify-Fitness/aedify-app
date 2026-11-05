package com.example.aedify

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.concurrent.Executors
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/** App-owned local metadata only; errors never contain source paths or platform details. */
class ProgressVideoMetadata(context: Context, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "aedify/progress_video")
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private val roots = listOf(context.filesDir.canonicalFile, context.cacheDir.canonicalFile)

    init {
        channel.setMethodCallHandler { call, result ->
            if (call.method != "inspect") { result.notImplemented() }
            else {
                val path = call.argument<String>("path")
                val maxDuration = call.argument<Number>("maxDurationMs")?.toLong()
                val maxBytes = call.argument<Number>("maxBytes")?.toLong()
                val edge = call.argument<Number>("thumbnailEdge")?.toInt()
                if (path == null || maxDuration == null || maxBytes == null || edge == null ||
                    maxDuration <= 0 || maxDuration > 60000 || maxBytes <= 0 || edge !in 1..512) {
                    result.error("invalid", null, null)
                } else {
                    worker.execute {
                        try {
                            val metadata = inspect(File(path), maxDuration, maxBytes, edge)
                            main.post { result.success(metadata) }
                        } catch (failure: VideoFailure) {
                            main.post { result.error(failure.code, null, null) }
                        } catch (_: Exception) {
                            main.post { result.error("invalid", null, null) }
                        }
                    }
                }
            }
        }
    }

    private fun inspect(source: File, maxDuration: Long, maxBytes: Long, edge: Int): Map<String, Any?> {
        val file = source.canonicalFile
        if (!file.isFile || roots.none { file.path.startsWith(it.path + File.separator) }) throw VideoFailure("invalid")
        if (file.length() > maxBytes) throw VideoFailure("too_large")
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(file.path)
            if (retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_HAS_VIDEO) != "yes") throw VideoFailure("invalid")
            val duration = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0
            val width = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)?.toIntOrNull() ?: 0
            val height = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)?.toIntOrNull() ?: 0
            if (duration <= 0 || width <= 0 || height <= 0) throw VideoFailure("invalid")
            if (duration > maxDuration) throw VideoFailure("too_long")
            // API 26 cannot request a scaled decode; bound its fallback allocation.
            if (Build.VERSION.SDK_INT < 27 && width.toLong() * height > 16000000) throw VideoFailure("too_large")
            val scale = min(1.0, edge.toDouble() / max(width, height))
            val targetWidth = max(1, (width * scale).roundToInt())
            val targetHeight = max(1, (height * scale).roundToInt())
            val thumbnail = try {
                val bitmap = if (Build.VERSION.SDK_INT >= 27) {
                    retriever.getScaledFrameAtTime(0, MediaMetadataRetriever.OPTION_CLOSEST_SYNC, targetWidth, targetHeight)
                } else retriever.getFrameAtTime(0, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                bitmap?.let {
                    val bounded = if (max(it.width, it.height) > edge) Bitmap.createScaledBitmap(it, targetWidth, targetHeight, true) else it
                    try {
                        ByteArrayOutputStream().use { output -> bounded.compress(Bitmap.CompressFormat.PNG, 100, output); output.toByteArray() }
                    } finally { if (bounded !== it) bounded.recycle(); it.recycle() }
                }
            } catch (_: Exception) { null }
            val rotation = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)?.toIntOrNull() ?: 0
            return mapOf("durationMs" to duration, "width" to if (rotation % 180 == 0) width else height,
                "height" to if (rotation % 180 == 0) height else width, "thumbnail" to thumbnail)
        } finally { retriever.release() }
    }

    fun dispose() { channel.setMethodCallHandler(null); worker.shutdown() }
    private class VideoFailure(val code: String) : Exception()
}
