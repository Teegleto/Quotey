import Foundation

enum DiffToken: Equatable {
    case match(String)
    case missing(String)   // in expected, not in attempt
    case extra(String)     // in attempt, not in expected
}

struct DiffResult {
    let tokens: [DiffToken]
    let expectedCount: Int
    let matchedCount: Int

    var accuracy: Double {
        guard expectedCount > 0 else { return 1.0 }
        return Double(matchedCount) / Double(expectedCount)
    }
}

struct TextDiff {
    static func diff(expected: String, attempt: String) -> DiffResult {
        let expectedWords = words(in: expected)
        let attemptWords = words(in: attempt)
        let normExpected = expectedWords.map(normalize)
        let normAttempt = attemptWords.map(normalize)

        let lcs = longestCommonSubsequence(normExpected, normAttempt)

        var tokens: [DiffToken] = []
        var i = 0, j = 0, k = 0
        while i < expectedWords.count || j < attemptWords.count {
            if k < lcs.count, i < expectedWords.count, j < attemptWords.count,
               normExpected[i] == lcs[k], normAttempt[j] == lcs[k] {
                tokens.append(.match(expectedWords[i]))
                i += 1; j += 1; k += 1
            } else if i < expectedWords.count, (k >= lcs.count || normExpected[i] != lcs[k]) {
                tokens.append(.missing(expectedWords[i]))
                i += 1
            } else if j < attemptWords.count, (k >= lcs.count || normAttempt[j] != lcs[k]) {
                tokens.append(.extra(attemptWords[j]))
                j += 1
            }
        }

        return DiffResult(
            tokens: tokens,
            expectedCount: expectedWords.count,
            matchedCount: lcs.count
        )
    }

    private static func words(in text: String) -> [String] {
        text.split(whereSeparator: { $0.isWhitespace }).map(String.init)
    }

    private static func normalize(_ word: String) -> String {
        let stripped = word.unicodeScalars.filter { scalar in
            CharacterSet.letters.contains(scalar) || CharacterSet.decimalDigits.contains(scalar)
        }
        return String(String.UnicodeScalarView(stripped)).lowercased()
    }

    private static func longestCommonSubsequence(_ a: [String], _ b: [String]) -> [String] {
        let n = a.count, m = b.count
        if n == 0 || m == 0 { return [] }
        var dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        for i in 0..<n {
            for j in 0..<m {
                if a[i] == b[j] {
                    dp[i + 1][j + 1] = dp[i][j] + 1
                } else {
                    dp[i + 1][j + 1] = max(dp[i][j + 1], dp[i + 1][j])
                }
            }
        }
        var result: [String] = []
        var i = n, j = m
        while i > 0 && j > 0 {
            if a[i - 1] == b[j - 1] {
                result.append(a[i - 1])
                i -= 1; j -= 1
            } else if dp[i - 1][j] >= dp[i][j - 1] {
                i -= 1
            } else {
                j -= 1
            }
        }
        return result.reversed()
    }
}
