import Flutter
import UIKit
import UserNotifications
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var analyticsExport: AnalyticsCsvExport?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AedifyAnalyticsExport") {
      analyticsExport?.cancel()
      let exporter = AnalyticsCsvExport()
      analyticsExport = exporter
      let channel = FlutterMethodChannel(name: "aedify/analytics_export", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        if call.method == "cancel" { exporter.cancel(); result(nil); return }
        guard call.method == "save", let args = call.arguments as? [String: Any],
              let data = args["bytes"] as? FlutterStandardTypedData else {
          result(FlutterError(code: "unavailable", message: nil, details: nil)); return
        }
        exporter.save(data.data, result: result)
      }
    }
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

/// Owns only an explicitly requested CSV and removes its temporary copy on exit.
private final class AnalyticsCsvExport: NSObject, UIDocumentPickerDelegate, UIAdaptivePresentationControllerDelegate {
  private var pending: FlutterResult?
  private var folder: URL?
  private var picker: UIDocumentPickerViewController?
  override init() {
    super.init()
    let base = FileManager.default.temporaryDirectory
    for directory in (try? FileManager.default.contentsOfDirectory(at: base, includingPropertiesForKeys: nil)) ?? [] {
      let name = directory.lastPathComponent
      guard name.hasPrefix("aedify_export_"), UUID(uuidString: String(name.dropFirst("aedify_export_".count))) != nil else { continue }
      try? FileManager.default.removeItem(at: directory)
    }
  }
  func save(_ data: Data, result: @escaping FlutterResult) {
    guard pending == nil, !data.isEmpty, data.count <= 8388608 else {
      result(FlutterError(code: "unavailable", message: nil, details: nil)); return
    }
    let root = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }.first { $0.isKeyWindow }?.rootViewController
    guard var top = root else { result(FlutterError(code: "unavailable", message: nil, details: nil)); return }
    while let presented = top.presentedViewController { top = presented }
    pending = result
    do {
      let directory = FileManager.default.temporaryDirectory.appendingPathComponent("aedify_export_\(UUID().uuidString)", isDirectory: true)
      folder = directory
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
      let file = directory.appendingPathComponent("aedify_analytics.csv")
      try data.write(to: file, options: [.atomic, .completeFileProtection])
      let controller = UIDocumentPickerViewController(forExporting: [file], asCopy: true)
      picker = controller
      controller.delegate = self
      top.present(controller, animated: true)
      controller.presentationController?.delegate = self
    } catch { finish(false, failed: true) }
  }
  func cancel() { picker?.dismiss(animated: false); finish(false) }
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { finish(false) }
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) { finish(!urls.isEmpty) }
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) { finish(false) }
  private func finish(_ saved: Bool, failed: Bool = false) {
    let result = pending
    pending = nil
    picker = nil
    if let directory = folder { try? FileManager.default.removeItem(at: directory) }
    folder = nil
    if failed { result?(FlutterError(code: "unavailable", message: nil, details: nil)) }
    else { result?(saved) }
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
