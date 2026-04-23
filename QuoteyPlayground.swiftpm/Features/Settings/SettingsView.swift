import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var quotes: [Quote]
    @Query private var tags: [Tag]
    @Query private var reviews: [ReviewLog]

    @State private var exportDocument: JSONExportDocument?
    @State private var showExporter = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Library") {
                    LabeledContent("Quotes", value: "\(quotes.count)")
                    LabeledContent("Tags", value: "\(tags.count)")
                    LabeledContent("Reviews", value: "\(reviews.count)")
                }

                Section("Export") {
                    Button("Export library as JSON") { prepareExport() }
                        .disabled(quotes.isEmpty)
                }

                Section("iCloud") {
                    Text("Quotey syncs through your iCloud account's private database. Open Settings › iCloud to confirm you're signed in and that iCloud Drive is on.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("About") {
                    LabeledContent("Version", value: Bundle.main.versionString)
                }
            }
            .navigationTitle("Settings")
            .fileExporter(
                isPresented: $showExporter,
                document: exportDocument,
                contentType: .json,
                defaultFilename: "quotey-library"
            ) { _ in }
        }
    }

    private func prepareExport() {
        do {
            let data = try ImportExport.jsonExport(for: quotes)
            exportDocument = JSONExportDocument(data: data)
            showExporter = true
        } catch {
            // Surface via an alert in a later polish pass.
        }
    }
}

private extension Bundle {
    var versionString: String {
        let v = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}

struct JSONExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data

    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
