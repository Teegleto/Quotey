import XCTest
@testable import Quotey

final class FillBlankGeneratorTests: XCTestCase {
    func testSeededMaskingIsDeterministic() {
        let text = "The unexamined life is not worth living for a human being."
        let a = FillBlankGenerator.generate(text: text, maskRatio: 0.5, seed: 42)
        let b = FillBlankGenerator.generate(text: text, maskRatio: 0.5, seed: 42)
        XCTAssertEqual(a, b)
    }

    func testZeroRatioMasksNothing() {
        let text = "Hello there, general Kenobi."
        let segments = FillBlankGenerator.generate(text: text, maskRatio: 0, seed: 1)
        for seg in segments {
            if case .blank = seg { XCTFail("unexpected blank"); return }
        }
    }

    func testStopwordsAreNotMasked() {
        let text = "the cat sat on the windowsill"
        let segments = FillBlankGenerator.generate(text: text, maskRatio: 1.0, seed: 7)
        for seg in segments {
            if case .blank(let answer) = seg {
                XCTAssertFalse(
                    FillBlankGenerator.stopWords.contains(answer.lowercased()),
                    "stop word was masked: \(answer)"
                )
            }
        }
    }

    func testReconstructionMatchesOriginal() {
        let text = "Rage, rage against the dying of the light."
        let segments = FillBlankGenerator.generate(text: text, maskRatio: 0.4, seed: 13)
        let reconstructed = segments.map { seg -> String in
            switch seg {
            case .text(let t): return t
            case .blank(let answer): return answer
            }
        }.joined()
        XCTAssertEqual(reconstructed, text)
    }
}
