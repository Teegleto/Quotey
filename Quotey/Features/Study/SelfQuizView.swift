import SwiftUI

struct SelfQuizView: View {
    @Environment(\.dismiss) private var dismiss
    let queue: [Quote]

    @State private var index = 0
    @State private var revealed = false

    private var current: Quote? {
        queue.indices.contains(index) ? queue[index] : nil
    }

    var body: some View {
        VStack {
            if let quote = current {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        GroupBox("Prompt") {
                            if quote.context.isEmpty {
                                Text(quote.author ?? quote.source ?? "(no context)")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(quote.context)
                            }
                        }
                        if revealed {
                            GroupBox("Quote") {
                                Text(quote.text)
                            }
                        }
                    }
                    .padding()
                }
                controls
            } else {
                ContentUnavailableView(
                    "All done",
                    systemImage: "checkmark.seal"
                )
            }
        }
        .navigationTitle("Self-quiz · \(min(index + 1, queue.count))/\(queue.count)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }

    private var controls: some View {
        HStack {
            Button(revealed ? "Next" : "Reveal") {
                if revealed {
                    index += 1
                    revealed = false
                } else {
                    withAnimation { revealed = true }
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}
