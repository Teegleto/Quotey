import SwiftUI
import SwiftData

struct QuoteEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: [SortDescriptor(\Tag.name)]) private var allTags: [Tag]

    var editing: Quote?
    var prefillText: String = ""

    @State private var text: String = ""
    @State private var context_: String = ""
    @State private var source: String = ""
    @State private var author: String = ""
    @State private var selectedTagIDs: Set<UUID> = []
    @State private var newTagName: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Quote") {
                    TextEditor(text: $text)
                        .frame(minHeight: 120)
                }
                Section("Context") {
                    TextEditor(text: $context_)
                        .frame(minHeight: 80)
                }
                Section("Attribution") {
                    TextField("Author", text: $author)
                    TextField("Source (book, article, URL)", text: $source)
                }
                Section("Tags") {
                    ForEach(allTags) { tag in
                        Button {
                            toggle(tag)
                        } label: {
                            HStack {
                                Text(tag.name)
                                Spacer()
                                if selectedTagIDs.contains(tag.id) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    HStack {
                        TextField("New tag", text: $newTagName)
                        Button("Add") { addTag() }
                            .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .navigationTitle(editing == nil ? "New quote" : "Edit quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: populate)
        }
    }

    private func populate() {
        guard let editing else {
            text = prefillText
            return
        }
        text = editing.text
        context_ = editing.context
        source = editing.source ?? ""
        author = editing.author ?? ""
        selectedTagIDs = Set((editing.tags ?? []).map(\.id))
    }

    private func toggle(_ tag: Tag) {
        if selectedTagIDs.contains(tag.id) {
            selectedTagIDs.remove(tag.id)
        } else {
            selectedTagIDs.insert(tag.id)
        }
    }

    private func addTag() {
        let name = newTagName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        if let existing = allTags.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
            selectedTagIDs.insert(existing.id)
        } else {
            let tag = Tag(name: name)
            context.insert(tag)
            selectedTagIDs.insert(tag.id)
        }
        newTagName = ""
    }

    private func save() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let chosenTags = allTags.filter { selectedTagIDs.contains($0.id) }
        if let editing {
            editing.text = trimmed
            editing.context = context_
            editing.source = source.isEmpty ? nil : source
            editing.author = author.isEmpty ? nil : author
            editing.tags = chosenTags
            editing.updatedAt = Date()
        } else {
            let quote = Quote(
                text: trimmed,
                context: context_,
                source: source.isEmpty ? nil : source,
                author: author.isEmpty ? nil : author,
                tags: chosenTags
            )
            context.insert(quote)
        }
        dismiss()
    }
}
