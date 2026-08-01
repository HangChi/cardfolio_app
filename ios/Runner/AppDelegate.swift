import Flutter
import UIKit
import Vision

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
    let channel = FlutterMethodChannel(
      name: "cardfolio/text_recognition",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "recognize" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let arguments = call.arguments as? [String: Any],
        let path = arguments["imagePath"] as? String,
        !path.isEmpty,
        let cgImage = UIImage(contentsOfFile: path)?.cgImage
      else {
        result(FlutterError(code: "invalid_image", message: "无法读取图片", details: nil))
        return
      }

      let request = VNRecognizeTextRequest { request, error in
        if let error = error {
          DispatchQueue.main.async {
            result(FlutterError(code: "recognition_failed", message: error.localizedDescription, details: nil))
          }
          return
        }
        let lines = (request.results as? [VNRecognizedTextObservation] ?? []).compactMap {
          $0.topCandidates(1).first?.string
        }
        DispatchQueue.main.async { result(lines.joined(separator: "\n")) }
      }
      request.recognitionLevel = .accurate
      request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US"]
      request.usesLanguageCorrection = true

      DispatchQueue.global(qos: .userInitiated).async {
        do {
          try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "recognition_failed", message: error.localizedDescription, details: nil))
          }
        }
      }
    }
  }
}
