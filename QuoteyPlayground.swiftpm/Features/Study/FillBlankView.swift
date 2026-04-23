import SwiftUI

struct FillBlankView: View {
    @Environment(\.dismiss) private var dismiss
    let queue: [Quote]

    @State private var index = 0
    @State private var segments: [FillBlankSegment] = []
    @State private var revealedBlanks: Set<Int> = []

    private var current: Quote? {
        queue.indices.contains(index) ? queue[index] : nil
    }

    var body: some View {
        VStack {
            if let quote = current {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if !quote.context.isEmpty {
                            GroupBox("Context") {
                                Text(quote.context).foregroundStyle(.secondary)
                            }
                        }
                        sentenceView
                        if let author = quote.author {
                            Text("— \(author)").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                }
                controls
            } else {
                ContentUnavailableView("All done", systemImage: "checkmark.seal")
            }
        }
        .navigationTitle("Fill-in · \(min(index + 1, queue.count))/\(queue.count)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
        .onAppear(perform: regenerate)
        .onChange(of: index) { _, _ in regenerate() }
    }

    private var sentenceView: some View {
        FlowLayout(spacing: 4) {
            ForEach(Array(segments.enumerated()), id: \.offset) { idx, segment in
                segmentView(idx: idx, segment: segment)
            }
        }
    }

    @ViewBuilder
    private func segmentView(idx: Int, segment: FillBlankSegment) -> some View {
        switch segment {
        case .text(let t):
            Text(t)
        case .blank(let answer):
            Button {
                if revealedBlanks.contains(idx) {
                    revealedBlanks.remove(idx)
                } else {
                    revealedBlanks.insert(idx)
                }
            } label: {
                Text(revealedBlanks.contains(idx) ? answer : String(repeating: "_", count: max(3, answer.count)))
                    .font(.body.monospaced())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(revealedBlanks.contains(idx) ? Color.green.opacity(0.2) : Color.yellow.opacity(0.25))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var controls: some View {
        HStack {
            Button("Reveal all") {
                revealedBlanks = Set(segments.indices.filter {
                    if case .blank = segments[$0] { return true } else { return false }
                })
            }
            Spacer()
            Button("Next") {
                if index + 1 < queue.count { index += 1 } else { index = queue.count }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func regenerate() {
        guard let quote = current else { segments = []; return }
        segments = FillBlankGenerator.generate(text: quote.text)
        revealedBlanks = []
    }
}

/// Simple flowing layout so the sentence wraps like normal text.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var totalHeight: CGFloat = 0
        var x: CGFloat = 0
        var lineHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                totalHeight += lineHeight + spacing
                x = 0
                lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        totalHeight += lineHeight
        return CGSize(width: maxWidth.isFinite ? maxWidth : x, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
