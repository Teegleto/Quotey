import XCTest
@testable import Quotey

final class SRSSchedulerTests: XCTestCase {
    private let epoch = Date(timeIntervalSince1970: 1_700_000_000)

    private func fresh() -> SRSScheduler.State {
        SRSScheduler.State(
            easeFactor: 2.5,
            intervalDays: 0,
            repetitions: 0,
            lapses: 0,
            dueDate: epoch,
            lastReviewedAt: nil
        )
    }

    func testFirstGoodReviewSchedulesOneDayOut() {
        let next = SRSScheduler.apply(grade: .good, to: fresh(), now: epoch)
        XCTAssertEqual(next.repetitions, 1)
        XCTAssertEqual(next.intervalDays, 1)
        XCTAssertGreaterThan(next.easeFactor, 2.5)
    }

    func testSecondGoodReviewSchedulesSixDaysOut() {
        var state = SRSScheduler.apply(grade: .good, to: fresh(), now: epoch)
        state = SRSScheduler.apply(grade: .good, to: state, now: epoch)
        XCTAssertEqual(state.repetitions, 2)
        XCTAssertEqual(state.intervalDays, 6)
    }

    func testSubsequentIntervalScalesByEase() {
        var state = fresh()
        state = SRSScheduler.apply(grade: .good, to: state, now: epoch) // rep 1, interval 1
        state = SRSScheduler.apply(grade: .good, to: state, now: epoch) // rep 2, interval 6
        let ef = state.easeFactor
        state = SRSScheduler.apply(grade: .good, to: state, now: epoch) // rep 3, interval ≈ 6 * EF
        XCTAssertEqual(state.repetitions, 3)
        XCTAssertEqual(state.intervalDays, Int((6.0 * ef).rounded()))
    }

    func testAgainResetsRepetitionsAndLapses() {
        var state = SRSScheduler.apply(grade: .good, to: fresh(), now: epoch)
        state = SRSScheduler.apply(grade: .good, to: state, now: epoch)
        state = SRSScheduler.apply(grade: .again, to: state, now: epoch)
        XCTAssertEqual(state.repetitions, 0)
        XCTAssertEqual(state.intervalDays, 1)
        XCTAssertEqual(state.lapses, 1)
    }

    func testEaseFactorIsClampedAtMinimum() {
        var state = fresh()
        for _ in 0..<20 {
            state = SRSScheduler.apply(grade: .again, to: state, now: epoch)
        }
        XCTAssertGreaterThanOrEqual(state.easeFactor, SRSScheduler.minimumEaseFactor)
    }

    func testDueDateAdvancesByIntervalDays() {
        let cal = Calendar(identifier: .gregorian)
        let next = SRSScheduler.apply(grade: .easy, to: fresh(), now: epoch)
        let expected = cal.date(byAdding: .day, value: next.intervalDays, to: epoch)!
        XCTAssertEqual(next.dueDate.timeIntervalSince1970,
                       expected.timeIntervalSince1970,
                       accuracy: 1)
    }
}
