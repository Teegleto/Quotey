import SwiftUI

struct RecitationView: View {
    @Environment(\.dismiss) private var dismiss
    let queue: [Quote]

    @State private var index = 0
    @State private var attempt = ""
    @State private var result: DiffResult?

    private var current: Quote? {
        queue.indices.contains(index) ? queue[index] : nil
    }

    var body: some View {
        VStack {
            if let quote = current {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if !quote.context.isEmpty {
                            GroupBox("Prompt") { Text(quote.context) }
                        }
                        GroupBox("Your attempt") {
                            TextEditor(text: $attempt).frame(minHeight: 150)
                        }
                        if let result {
                            GroupBox("Result · \(Int((result.accuracy * 100).rounded()))%") {
                                diffView(result: result)
                                Text(quote.text).font(.footnote).foregroundStyle(.secondary).padding(.top, 8)
                            }
                        }
                    }
                    .padding()
                }
                controls(for: quote)
            } else {
                ContentUnavailableView("All done", systemImage: "checkmark.seal")
            }
        }
        .navigationTitle("Recite · \(min(index + 1, queue.count))/\(queue.count)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }

    private func diffView(result: DiffResult) -> some View {
        result.tokens.reduce(Text("")) { acc, token in
            let piece: Text
            switch token {
            case .match(let w):
                piece = Text(w).foregroundColor(.primary)
            case .missing(let w):
                piece = Text(w).foregroundColor(.red).strikethrough()
            case .extra(let w):
                piece = Text(w).foregroundColor(.orange).underline()
            }
            return acc + piece + Text(" ")
        }
    }

    private func controls(for quote: Quote) -> some View {
        HStack {
            Button("Check") {
                result = TextDiff.diff(expected: quote.text, attempt: attempt)
            }
            .disabled(attempt.trimmingCharacters(in: .whitespaces).isEmpty)
            Spacer()
            Button("Next") {
                attempt = ""
                result = nil
                if index + 1 < queue.count { index += 1 } else { index = queue.count }
            }
            .buttonStyle(.borderedProminent)
            .disabled(result == nil)
        }
        .padding()
    }
}
