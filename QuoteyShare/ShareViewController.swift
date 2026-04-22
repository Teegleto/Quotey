import UIKit
import Social
import UniformTypeIdentifiers

/// Accepts shared text or a URL from the iOS Share Sheet and drops a JSON
/// "pending import" file into the App Group container. The main app picks it
/// up the next time it comes to the foreground.
final class ShareViewController: SLComposeServiceViewController {

    private var sharedText: String = ""
    private var sharedURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        placeholder = "Add context or notes (optional)…"
        title = "Quotey"
        loadAttachments()
    }

    override func isContentValid() -> Bool { !sharedText.isEmpty || sharedURL != nil }

    override func didSelectPost() {
        let payload = QuotePayload(
            text: sharedText,
            context: contentText,
            source: sharedURL?.absoluteString,
            author: nil,
            tags: nil
        )
        if let data = try? JSONEncoder().encode(payload),
           let dir = AppGroup.pendingImportsDirectory() {
            let file = dir.appendingPathComponent("\(UUID().uuidString).json")
            try? data.write(to: file, options: .atomic)
        }
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! { [] }

    private func loadAttachments() {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem else { return }
        for attachment in item.attachments ?? [] {
            if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier) { [weak self] data, _ in
                    if let text = data as? String { self?.sharedText = text }
                    DispatchQueue.main.async { self?.validateContent() }
                }
            } else if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                attachment.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] data, _ in
                    if let url = data as? URL { self?.sharedURL = url }
                    DispatchQueue.main.async { self?.validateContent() }
                }
            }
        }
    }
}

/// Mirrors the same keys used in the main app, so the JSON can be decoded there.
struct QuotePayload: Codable {
    var text: String
    var context: String?
    var source: String?
    var author: String?
    var tags: [String]?
}

enum AppGroup {
    static let identifier = "group.com.quotey.shared"
    static let pendingImportsSubdir = "pending"

    static func pendingImportsDirectory() -> URL? {
        guard let base = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: identifier
        ) else { return nil }
        let dir = base.appendingPathComponent(pendingImportsSubdir, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
}
