import XCTest
@testable import Quotey

final class TextDiffTests: XCTestCase {
    func testPerfectMatchHasFullAccuracy() {
        let r = TextDiff.diff(
            expected: "the only way out is through",
            attempt: "The only way out is through."
        )
        XCTAssertEqual(r.accuracy, 1.0, accuracy: 0.0001)
        for t in r.tokens {
            if case .match = t {} else { XCTFail("non-match token: \(t)") }
        }
    }

    func testMissingWordsAreFlagged() {
        let r = TextDiff.diff(
            expected: "to be or not to be",
            attempt: "to be not be"
        )
        let missing = r.tokens.compactMap { token -> String? in
            if case .missing(let w) = token { return w } else { return nil }
        }
        XCTAssertEqual(missing, ["or", "to"])
    }

    func testExtraWordsAreFlagged() {
        let r = TextDiff.diff(
            expected: "I think therefore I am",
            attempt: "I really think therefore I am today"
        )
        let extras = r.tokens.compactMap { token -> String? in
            if case .extra(let w) = token { return w } else { return nil }
        }
        XCTAssertEqual(extras, ["really", "today"])
        XCTAssertEqual(r.accuracy, 1.0, accuracy: 0.0001) // all expected words matched
    }

    func testPunctuationIsNormalized() {
        let r = TextDiff.diff(expected: "Hello, world!", attempt: "hello world")
        XCTAssertEqual(r.accuracy, 1.0, accuracy: 0.0001)
    }
}
