import SwiftUI
import SwiftData

struct QuoteDetailView: View {
    @Bindable var quote: Quote
    @State private var showEditor = false
    @State private var studyMode: StudyMode?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(quote.text)
                    .font(.title3)
                    .textSelection(.enabled)

                if !quote.context.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Context").font(.headline)
                        Text(quote.context).textSelection(.enabled)
                    }
                }

                metadata

                if let tags = quote.tags, !tags.isEmpty {
                    TagChipsRow(tags: tags)
                }

                srsStatus

                studyActions
            }
            .padding()
        }
        .navigationTitle("Quote")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showEditor = true }
            }
        }
        .sheet(isPresented: $showEditor) {
            QuoteEditorView(editing: quote)
        }
        .sheet(item: $studyMode) { mode in
            singleStudySheet(mode: mode)
        }
    }

    @ViewBuilder
    private var metadata: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let author = quote.author, !author.isEmpty {
                Label(author, systemImage: "person").font(.subheadline)
            }
            if let source = quote.source, !source.isEmpty {
                Label(source, systemImage: "book").font(.subheadline)
            }
        }
        .foregroundStyle(.secondary)
    }

    private var srsStatus: some View {
        GroupBox("Spaced repetition") {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Repetitions"); Spacer(); Text("\(quote.repetitions)")
                }
                HStack {
                    Text("Interval"); Spacer(); Text("\(quote.intervalDays) days")
                }
                HStack {
                    Text("Ease"); Spacer(); Text(String(format: "%.2f", quote.easeFactor))
                }
                HStack {
                    Text("Next review"); Spacer()
                    Text(quote.dueDate, style: .date)
                }
            }
            .font(.subheadline)
        }
    }

    private var studyActions: some View {
        VStack(spacing: 8) {
            ForEach(StudyMode.allCases, id: \.self) { mode in
                Button {
                    studyMode = mode
                } label: {
                    Label(mode.label, systemImage: icon(for: mode))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func icon(for mode: StudyMode) -> String {
        switch mode {
        case .srs: "repeat"
        case .selfQuiz: "questionmark.app"
        case .fillBlank: "text.badge.plus"
        case .recitation: "mic"
        }
    }

    @ViewBuilder
    private func singleStudySheet(mode: StudyMode) -> some View {
        NavigationStack {
            switch mode {
            case .srs:
                SRSSessionView(queue: [quote])
            case .selfQuiz:
                SelfQuizView(queue: [quote])
            case .fillBlank:
                FillBlankView(queue: [quote])
            case .recitation:
                RecitationView(queue: [quote])
            }
        }
    }
}

extension StudyMode: Identifiable {
    var id: String { rawValue }
}

struct TagChipsRow: View {
    let tags: [Tag]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags) { tag in
                    Text(tag.name)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                }
            }
        }
    }
}
