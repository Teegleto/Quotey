import Foundation
import Vision
import UIKit

/// Static text-recognition helpers used when the user picks an image from the
/// photo library. Live camera scanning is handled separately by
/// `OCRCaptureView` (VisionKit `DataScannerViewController`).
enum OCRService {
    static func recognizeText(in image: UIImage) async -> String {
        guard let cgImage = image.cgImage else { return "" }
        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: cleanup(lines.joined(separator: "\n")))
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: "")
                }
            }
        }
    }

    static func cleanup(_ raw: String) -> String {
        // Collapse soft-wrapped lines: a line that doesn't end with punctuation
        // is treated as a wrap of the next line.
        let lines = raw.components(separatedBy: "\n")
        var output = ""
        for (idx, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            output += trimmed
            let endsParagraph = trimmed.last.map { ".!?\"”'’".contains($0) } ?? true
            if idx < lines.count - 1 {
                output += endsParagraph ? "\n" : " "
            }
        }
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
