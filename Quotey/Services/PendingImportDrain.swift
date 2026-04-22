import Foundation
import SwiftData

/// Reads quote payloads that the Share Extension has dropped into the App Group
/// container, inserts them into the main SwiftData store, and deletes the files.
enum PendingImportDrain {
    @MainActor
    static func drain(into context: ModelContext) async {
        guard let dir = AppGroup.pendingImportsDirectory() else { return }
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else {
            return
        }
        let decoder = JSONDecoder()
        for file in files where file.pathExtension == "json" {
            guard let data = try? Data(contentsOf: file) else { continue }
            if let payload = try? decoder.decode(QuotePayload.self, from: data) {
                ImportExport.insert(payloads: [payload], into: context)
            } else if let payloads = try? decoder.decode([QuotePayload].self, from: data) {
                ImportExport.insert(payloads: payloads, into: context)
            }
            try? fm.removeItem(at: file)
        }
        try? context.save()
    }
}
