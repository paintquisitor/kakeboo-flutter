import Flutter
import UIKit
import PDFKit
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
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "KakeboLocalDocuments")!
    let channel = FlutterMethodChannel(name: "pl.kakebo/local_documents", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      guard ["readPdf", "readReceipt"].contains(call.method) else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let arguments = call.arguments as? [String: Any],
            let path = arguments["path"] as? String, path.hasPrefix("/") else {
        result(FlutterError(code: "invalid_path", message: "Expected an absolute local path", details: nil))
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        let url = URL(fileURLWithPath: path)
        if call.method == "readReceipt" {
          do {
            let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard size > 0, size <= 25 * 1024 * 1024 else {
              throw NSError(domain: "KakeboDocuments", code: 1)
            }
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            let supported = try request.supportedRecognitionLanguages()
            let preferred = ["pl-PL", "en-US"].filter { supported.contains($0) }
            if !preferred.isEmpty { request.recognitionLanguages = preferred }
            try VNImageRequestHandler(url: url, options: [:]).perform([request])
            let lines: [[String: Any]] = (request.results ?? []).compactMap { observation in
              guard let text = observation.topCandidates(1).first?.string else { return nil }
              let box = observation.boundingBox
              return ["text": text, "left": box.minX, "top": 1 - box.maxY, "height": box.height]
            }
            DispatchQueue.main.async { result(lines) }
          } catch {
            DispatchQueue.main.async {
              result(FlutterError(code: "ocr_failed", message: "Cannot read this image", details: nil))
            }
          }
          return
        }
        guard let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize,
              size > 0, size <= 50 * 1024 * 1024,
              let document = PDFDocument(url: url), !document.isEncrypted,
              document.pageCount > 0, document.pageCount <= 500 else {
          DispatchQueue.main.async {
            result(FlutterError(code: "pdf_read_failed", message: "Cannot read this PDF", details: nil))
          }
          return
        }
        let pages = (0..<document.pageCount).map { index -> String in
          guard let page = document.page(at: index),
                let selection = page.selection(for: NSRange(location: 0, length: page.numberOfCharacters)) else {
            return ""
          }
          // PDFKit can follow drawing order. Match PDFBox sortByPosition:
          // top to bottom, then left to right within a visual row.
          let lines = selection.selectionsByLine().sorted {
            $0.bounds(for: page).midY > $1.bounds(for: page).midY
          }
          var rows: [[PDFSelection]] = []
          for line in lines {
            let box = line.bounds(for: page)
            if let previous = rows.last?.first?.bounds(for: page),
               abs(previous.midY - box.midY) < min(previous.height, box.height) / 2 {
              rows[rows.count - 1].append(line)
            } else {
              rows.append([line])
            }
          }
          return rows.map { row in
            row.sorted { $0.bounds(for: page).minX < $1.bounds(for: page).minX }
              .compactMap { $0.string }.joined(separator: " ")
          }.joined(separator: "\n")
        }
        DispatchQueue.main.async { result(pages) }
      }
    }
  }
}
