import SwiftUI
import SwiftData

struct QuoteListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Quote.updatedAt, order: .reverse)])
    private var quotes: [Quote]

    @State private var search = ""
    @State private var showEditor = false
    @State private var showBulkImport = false
    @State private var showScanner = false
    @State private var prefillText = ""

    private var filtered: [Quote] {
        guard !search.isEmpty else { return quotes }
        let q = search.lowercased()
        return quotes.filter {
            $0.text.lowercased().contains(q)
            || $0.context.lowercased().contains(q)
            || ($0.author ?? "").lowercased().contains(q)
            || ($0.source ?? "").lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if quotes.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(filtered) { quote in
                            NavigationLink(value: quote) {
                                QuoteRow(quote: quote)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .searchable(text: $search, prompt: "Search quotes")
                }
            }
            .navigationTitle("Library")
            .navigationDestination(for: Quote.self) { QuoteDetailView(quote: $0) }
            .toolbar { toolbar }
            .sheet(isPresented: $showEditor) {
                QuoteEditorView(prefillText: prefillText)
            }
            .sheet(isPresented: $showBulkImport) { BulkImportView() }
            .sheet(isPresented: $showScanner) {
                OCRCaptureView { text in
                    prefillText = text
                    showScanner = false
                    showEditor = true
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Menu {
                Button {
                    prefillText = ""
                    showEditor = true
                } label: { Label("New quote", systemImage: "square.and.pencil") }
                Button {
                    showScanner = true
                } label: { Label("Scan text", systemImage: "text.viewfinder") }
                Button {
                    showBulkImport = true
                } label: { Label("Import CSV / JSON", systemImage: "square.and.arrow.down") }
            } label: {
                Image(systemName: "plus")
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No quotes yet", systemImage: "text.quote")
        } description: {
            Text("Add a quote by typing it, scanning a page, importing a file, or sharing text from another app.")
        } actions: {
            Button("New quote") {
                prefillText = ""
                showEditor = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(filtered[index])
        }
    }
}

private struct QuoteRow: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(quote.displayTitle)
                .font(.body)
                .lineLimit(2)
            HStack(spacing: 8) {
                if let author = quote.author, !author.isEmpty {
                    Text(author)
                }
                if let source = quote.source, !source.isEmpty {
                    Text("· \(source)")
                }
                if quote.isDue && quote.repetitions > 0 {
                    Text("· Due")
                        .foregroundStyle(.orange)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
