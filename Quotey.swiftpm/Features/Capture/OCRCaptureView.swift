import SwiftUI
import VisionKit

/// Wraps VisionKit's `DataScannerViewController` so the user can point their
/// camera at a page, tap a recognized line, and have it appear in the editor.
struct OCRCaptureView: UIViewControllerRepresentable {
    var onPick: (String) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        guard DataScannerViewController.isSupported,
              DataScannerViewController.isAvailable else {
            return UnavailableViewController(message: "Text scanning isn't available on this device.")
        }
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        context.coordinator.scanner = scanner
        try? scanner.startScanning()
        return scanner
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        weak var scanner: DataScannerViewController?
        let onPick: (String) -> Void
        private var accumulator: [String] = []

        init(onPick: @escaping (String) -> Void) { self.onPick = onPick }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didTapOn item: RecognizedItem
        ) {
            guard case let .text(text) = item else { return }
            accumulator.append(text.transcript)
            onPick(accumulator.joined(separator: " "))
            accumulator.removeAll()
            dataScanner.stopScanning()
        }
    }
}

private final class UnavailableViewController: UIViewController {
    let message: String
    init(message: String) { self.message = message; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
}
