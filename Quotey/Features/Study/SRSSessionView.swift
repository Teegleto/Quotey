import SwiftUI
import SwiftData

struct SRSSessionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let queue: [Quote]

    @State private var index = 0
    @State private var revealed = false
    @State private var startedAt = Date()

    private var current: Quote? {
        queue.indices.contains(index) ? queue[index] : nil
    }

    var body: some View {
        VStack(spacing: 0) {
            if let quote = current {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header(for: quote)

                        if !quote.context.isEmpty {
                            GroupBox("Context") {
                                Text(quote.context).textSelection(.enabled)
                            }
                        }

                        if revealed {
                            GroupBox("Quote") {
                                Text(quote.text).textSelection(.enabled)
                            }
                            .transition(.opacity)
                        } else {
                            Button {
                                withAnimation { revealed = true }
                            } label: {
                                Label("Reveal quote", systemImage: "eye")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }

                if revealed {
                    gradeBar(for: quote)
                }
            } else {
                finishedView
            }
        }
        .navigationTitle("Review · \(index + 1)/\(queue.count)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }

    private func header(for quote: Quote) -> some View {
        HStack(spacing: 8) {
            if let author = quote.author { Text(author) }
            if let source = quote.source { Text("· \(source)") }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private func gradeBar(for quote: Quote) -> some View {
        HStack(spacing: 8) {
            gradeButton(.again, label: "Again", tint: .red, quote: quote)
            gradeButton(.hard, label: "Hard", tint: .orange, quote: quote)
            gradeButton(.good, label: "Good", tint: .blue, quote: quote)
            gradeButton(.easy, label: "Easy", tint: .green, quote: quote)
        }
        .padding()
        .background(.bar)
    }

    private func gradeButton(_ grade: Grade, label: String, tint: Color, quote: Quote) -> some View {
        Button {
            apply(grade, to: quote)
        } label: {
            Text(label)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .tint(tint)
    }

    private func apply(_ grade: Grade, to quote: Quote) {
        let elapsed = Int(Date().timeIntervalSince(startedAt) * 1000)
        SRSScheduler.apply(grade: grade, to: quote)
        context.insert(ReviewLog(quoteID: quote.id, grade: grade, mode: .srs, elapsedMs: elapsed))
        try? context.save()
        advance()
    }

    private func advance() {
        revealed = false
        startedAt = Date()
        if index + 1 < queue.count {
            index += 1
        } else {
            index = queue.count
        }
    }

    private var finishedView: some View {
        ContentUnavailableView(
            "Session complete",
            systemImage: "checkmark.seal",
            description: Text("Nice — that's everything that was due.")
        )
    }
}
