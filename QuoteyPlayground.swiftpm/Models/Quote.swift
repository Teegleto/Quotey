import Foundation
import SwiftData

@Model
final class Quote {
    var id: UUID = UUID()
    var text: String = ""
    var context: String = ""
    var source: String?
    var author: String?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var tags: [Tag]? = []

    // SM-2 scheduler state.
    var easeFactor: Double = 2.5
    var intervalDays: Int = 0
    var repetitions: Int = 0
    var dueDate: Date = Date()
    var lapses: Int = 0
    var lastReviewedAt: Date?

    init(
        text: String,
        context: String = "",
        source: String? = nil,
        author: String? = nil,
        tags: [Tag] = []
    ) {
        self.id = UUID()
        self.text = text
        self.context = context
        self.source = source
        self.author = author
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = tags
        self.dueDate = Date()
    }
}

extension Quote {
    var displayTitle: String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 80 { return trimmed }
        return String(trimmed.prefix(80)) + "…"
    }

    var isDue: Bool { dueDate <= Date() }
}
