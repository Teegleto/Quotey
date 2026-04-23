import Foundation

struct SRSScheduler {
    struct State: Equatable {
        var easeFactor: Double
        var intervalDays: Int
        var repetitions: Int
        var lapses: Int
        var dueDate: Date
        var lastReviewedAt: Date?
    }

    static let minimumEaseFactor = 1.3

    static func apply(grade: Grade, to state: State, now: Date = Date()) -> State {
        var next = state
        next.lastReviewedAt = now

        if grade == .again {
            next.repetitions = 0
            next.intervalDays = 1
            next.lapses += 1
        } else {
            switch next.repetitions {
            case 0: next.intervalDays = 1
            case 1: next.intervalDays = 6
            default:
                let scaled = Double(next.intervalDays) * next.easeFactor
                next.intervalDays = max(1, Int(scaled.rounded()))
            }
            next.repetitions += 1
        }

        let g = Double(grade.rawValue)
        let delta = 0.1 - (5 - g) * (0.08 + (5 - g) * 0.02)
        next.easeFactor = max(minimumEaseFactor, next.easeFactor + delta)

        let cal = Calendar(identifier: .gregorian)
        next.dueDate = cal.date(byAdding: .day, value: next.intervalDays, to: now) ?? now
        return next
    }

    static func apply(grade: Grade, to quote: Quote, now: Date = Date()) {
        let state = State(
            easeFactor: quote.easeFactor,
            intervalDays: quote.intervalDays,
            repetitions: quote.repetitions,
            lapses: quote.lapses,
            dueDate: quote.dueDate,
            lastReviewedAt: quote.lastReviewedAt
        )
        let next = apply(grade: grade, to: state, now: now)
        quote.easeFactor = next.easeFactor
        quote.intervalDays = next.intervalDays
        quote.repetitions = next.repetitions
        quote.lapses = next.lapses
        quote.dueDate = next.dueDate
        quote.lastReviewedAt = next.lastReviewedAt
        quote.updatedAt = now
    }
}
