import Foundation

enum FillBlankSegment: Equatable {
    case text(String)
    case blank(answer: String)
}

struct FillBlankGenerator {
    static let stopWords: Set<String> = [
        "a", "an", "the", "and", "or", "but", "if", "of", "in", "on", "to",
        "for", "with", "at", "by", "as", "is", "are", "was", "were", "be",
        "been", "being", "it", "its", "this", "that", "these", "those", "i",
        "you", "he", "she", "we", "they", "them", "his", "her", "their", "our"
    ]

    static func generate(
        text: String,
        maskRatio: Double = 0.35,
        seed: UInt64? = nil
    ) -> [FillBlankSegment] {
        let ratio = max(0, min(1, maskRatio))
        let tokens = tokenize(text)
        let maskable = tokens.enumerated().compactMap { idx, token -> Int? in
            guard case let .word(w) = token.kind else { return nil }
            let key = w.lowercased()
            guard !stopWords.contains(key), w.count > 2 else { return nil }
            return idx
        }

        let targetCount = Int((Double(maskable.count) * ratio).rounded())
        let masked: Set<Int>
        if let seed {
            var rng = SeededRNG(seed: seed)
            masked = Set(maskable.shuffled(using: &rng).prefix(targetCount))
        } else {
            var rng = SystemRandomNumberGenerator()
            masked = Set(maskable.shuffled(using: &rng).prefix(targetCount))
        }

        var segments: [FillBlankSegment] = []
        for (i, token) in tokens.enumerated() {
            switch token.kind {
            case .word(let w):
                if masked.contains(i) {
                    segments.append(.blank(answer: w))
                } else {
                    append(.text(w), into: &segments)
                }
            case .separator(let s):
                append(.text(s), into: &segments)
            }
        }
        return segments
    }

    private static func append(_ seg: FillBlankSegment, into segments: inout [FillBlankSegment]) {
        if case .text(let new) = seg, case .text(let prev) = segments.last {
            segments[segments.count - 1] = .text(prev + new)
        } else {
            segments.append(seg)
        }
    }

    private struct Token {
        enum Kind {
            case word(String)
            case separator(String)
        }
        let kind: Kind
    }

    private static func tokenize(_ text: String) -> [Token] {
        var tokens: [Token] = []
        var current = ""
        var currentIsWord: Bool? = nil

        let isWord: (Character) -> Bool = { c in
            c.isLetter || c.isNumber || c == "'" || c == "’"
        }

        for ch in text {
            let wordChar = isWord(ch)
            if currentIsWord == nil {
                currentIsWord = wordChar
                current.append(ch)
            } else if currentIsWord == wordChar {
                current.append(ch)
            } else {
                tokens.append(.init(kind: currentIsWord == true ? .word(current) : .separator(current)))
                current = String(ch)
                currentIsWord = wordChar
            }
        }
        if !current.isEmpty, let w = currentIsWord {
            tokens.append(.init(kind: w ? .word(current) : .separator(current)))
        }
        return tokens
    }
}

struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 0xdeadbeef : seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z &>> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z &>> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z &>> 31)
    }
}
