import Flutter
import UIKit
import AVFoundation

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
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AedifyProgressVideo") {
      let channel = FlutterMethodChannel(name: "aedify/progress_video", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        guard call.method == "inspect" else { result(FlutterMethodNotImplemented); return }
        guard let arguments = call.arguments as? [String: Any],
              let path = arguments["path"] as? String,
              let maxDuration = arguments["maxDurationMs"] as? Int,
              let maxBytes = arguments["maxBytes"] as? Int,
              let edge = arguments["thumbnailEdge"] as? Int,
              maxDuration > 0, maxDuration <= 60000, maxBytes > 0, edge > 0, edge <= 512 else {
          result(FlutterError(code: "invalid", message: nil, details: nil)); return
        }
        Task {
          do {
            let metadata = try await ProgressVideoMetadata.inspect(path: path, maxDuration: maxDuration, maxBytes: maxBytes, edge: edge)
            await MainActor.run { result(metadata) }
          } catch let failure as ProgressVideoMetadata.Failure {
            await MainActor.run { result(FlutterError(code: failure.rawValue, message: nil, details: nil)) }
          } catch {
            await MainActor.run { result(FlutterError(code: "invalid", message: nil, details: nil)) }
          }
        }
      }
    }
  }
}

/// No remote URLs, external files, free-form metadata or platform errors cross this channel.
private enum ProgressVideoMetadata {
  enum Failure: String, Error { case invalid, too_long, too_large }
  static func inspect(path: String, maxDuration: Int, maxBytes: Int, edge: Int) async throws -> [String: Any] {
    let file = URL(fileURLWithPath: path).resolvingSymlinksInPath()
    let home = URL(fileURLWithPath: NSHomeDirectory()).resolvingSymlinksInPath().path + "/"
    guard file.path.hasPrefix(home), FileManager.default.fileExists(atPath: file.path) else { throw Failure.invalid }
    let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
    guard let size = attributes[.size] as? NSNumber, size.intValue > 0 else { throw Failure.invalid }
    guard size.intValue <= maxBytes else { throw Failure.too_large }
    let asset = AVURLAsset(url: file, options: [AVURLAssetReferenceRestrictionsKey: AVAssetReferenceRestrictions.forbidAll.rawValue])
    let duration = try await asset.load(.duration)
    let seconds = CMTimeGetSeconds(duration)
    guard seconds.isFinite, seconds > 0 else { throw Failure.invalid }
    guard seconds <= Double(maxDuration) / 1000 else { throw Failure.too_long }
    let milliseconds = Int(ceil(seconds * 1000))
    guard milliseconds <= maxDuration else { throw Failure.too_long }
    let tracks = try await asset.loadTracks(withMediaType: .video)
    guard let track = tracks.first else { throw Failure.invalid }
    let naturalSize = try await track.load(.naturalSize)
    let transform = try await track.load(.preferredTransform)
    let rotatedSize = naturalSize.applying(transform)
    guard rotatedSize.width.isFinite, rotatedSize.height.isFinite,
          abs(rotatedSize.width) >= 1, abs(rotatedSize.height) >= 1,
          abs(rotatedSize.width) <= 32768, abs(rotatedSize.height) <= 32768 else { throw Failure.invalid }
    let width = Int(abs(rotatedSize.width)), height = Int(abs(rotatedSize.height))
    guard width > 0, height > 0, try await asset.load(.isPlayable) else { throw Failure.invalid }
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    generator.maximumSize = CGSize(width: CGFloat(edge), height: CGFloat(edge))
    let thumbnail: Data? = await withCheckedContinuation { continuation in
      generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: .zero)]) { _, image, _, status, _ in
        if status == .succeeded, let image = image { continuation.resume(returning: UIImage(cgImage: image).pngData()) }
        else { continuation.resume(returning: nil) }
      }
    }
    var output: [String: Any] = ["durationMs": milliseconds, "width": width, "height": height]
    if let thumbnail = thumbnail { output["thumbnail"] = FlutterStandardTypedData(bytes: thumbnail) }
    return output
  }
}
