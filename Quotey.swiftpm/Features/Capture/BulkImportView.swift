import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct BulkImportView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var showPicker = false
    @State private var status: Status = .idle

    enum Status {
        case idle
        case success(Int)
        case failure(String)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Import") {
                    Button {
                        showPicker = true
                    } label: {
                        Label("Choose file…", systemImage: "doc.text")
                    }
                }
                switch status {
                case .idle:
                    EmptyView()
                case .success(let n):
                    Section {
                        Label("Imported \(n) quote\(n == 1 ? "" : "s").", systemImage: "checkmark.circle")
                            .foregroundStyle(.green)
                    }
                case .failure(let message):
                    Section {
                        Label(message, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }

                Section("Expected format") {
                    Text(formatHelp).font(.footnote)
                }
            }
            .navigationTitle("Bulk import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $showPicker,
                allowedContentTypes: [.json, .commaSeparatedText, .plainText],
                onCompletion: handle
            )
        }
    }

    private var formatHelp: String {
        """
        CSV: header row with any of `text`, `context`, `source`, `author`, `tags`. Tags are separated by `;` or `,`.
        JSON: an array of objects with the same keys.
        """
    }

    private func handle(_ result: Result<URL, Error>) {
        switch result {
        case .failure(let error):
            status = .failure(error.localizedDescription)
        case .success(let url):
            let access = url.startAccessingSecurityScopedResource()
            defer { if access { url.stopAccessingSecurityScopedResource() } }
            do {
                let payloads = try ImportExport.payloads(from: url)
                let count = ImportExport.insert(payloads: payloads, into: context)
                try context.save()
                status = .success(count)
            } catch {
                status = .failure(error.localizedDescription)
            }
        }
    }
}
