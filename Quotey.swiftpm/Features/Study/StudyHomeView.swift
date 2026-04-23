import SwiftUI
import SwiftData

struct StudyHomeView: View {
    @Query(sort: [SortDescriptor(\Quote.dueDate)]) private var quotes: [Quote]

    @State private var activeMode: StudyMode?

    private var dueQueue: [Quote] {
        let now = Date()
        return quotes.filter { $0.dueDate <= now }
    }

    private var libraryQueue: [Quote] {
        quotes.shuffled()
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    row(
                        mode: .srs,
                        subtitle: dueQueue.isEmpty
                            ? "Nothing due — come back later."
                            : "\(dueQueue.count) due",
                        disabled: dueQueue.isEmpty
                    )
                } header: {
                    Text("Today")
                } footer: {
                    Text("Spaced repetition schedules each quote with SM-2. Grade honestly — the scheduler will surface the ones you keep missing.")
                }

                Section {
                    row(mode: .selfQuiz, subtitle: "See the context, then reveal the quote.", disabled: quotes.isEmpty)
                    row(mode: .fillBlank, subtitle: "Random words are masked. Tap to reveal.", disabled: quotes.isEmpty)
                    row(mode: .recitation, subtitle: "Type the quote from memory; see the diff.", disabled: quotes.isEmpty)
                } header: {
                    Text("Free practice")
                } footer: {
                    Text("These modes run over your whole library without touching the spaced-repetition schedule.")
                }
            }
            .navigationTitle("Study")
            .sheet(item: $activeMode) { mode in
                NavigationStack {
                    switch mode {
                    case .srs: SRSSessionView(queue: dueQueue)
                    case .selfQuiz: SelfQuizView(queue: libraryQueue)
                    case .fillBlank: FillBlankView(queue: libraryQueue)
                    case .recitation: RecitationView(queue: libraryQueue)
                    }
                }
            }
            .overlay {
                if quotes.isEmpty {
                    ContentUnavailableView(
                        "Nothing to study yet",
                        systemImage: "brain.head.profile",
                        description: Text("Add quotes from the Library tab first.")
                    )
                }
            }
        }
    }

    private func row(mode: StudyMode, subtitle: String, disabled: Bool) -> some View {
        Button {
            activeMode = mode
        } label: {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.label).font(.body)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
    }
}
