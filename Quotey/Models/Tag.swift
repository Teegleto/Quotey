import Foundation
import SwiftData

@Model
final class Tag {
    var id: UUID = UUID()
    var name: String = ""
    var colorHex: String?

    @Relationship(inverse: \Quote.tags)
    var quotes: [Quote]? = []

    init(name: String, colorHex: String? = nil) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
    }
}
