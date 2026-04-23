import Foundation
import SwiftData

enum StudyMode: String, CaseIterable, Codable {
    case srs
    case selfQuiz
    case fillBlank
    case recitation

    var label: String {
        switch self {
        case .srs: "Spaced repetition"
        case .selfQuiz: "Self-quiz"
        case .fillBlank: "Fill in the blank"
        case .recitation: "Recitation"
        }
    }
}

enum Grade: Int, CaseIterable, Codable {
    case again = 0
    case hard = 3
    case good = 4
    case easy = 5
}

@Model
final class ReviewLog {
    var id: UUID = UUID()
    var quoteID: UUID = UUID()
    var reviewedAt: Date = Date()
    var gradeRaw: Int = 0
    var modeRaw: String = StudyMode.srs.rawValue
    var elapsedMs: Int = 0

    init(quoteID: UUID, grade: Grade, mode: StudyMode, elapsedMs: Int) {
        self.id = UUID()
        self.quoteID = quoteID
        self.reviewedAt = Date()
        self.gradeRaw = grade.rawValue
        self.modeRaw = mode.rawValue
        self.elapsedMs = elapsedMs
    }

    var grade: Grade { Grade(rawValue: gradeRaw) ?? .again }
    var mode: StudyMode { StudyMode(rawValue: modeRaw) ?? .srs }
}
