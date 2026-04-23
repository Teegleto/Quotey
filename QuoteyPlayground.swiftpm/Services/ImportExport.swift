import Foundation
import SwiftData

struct QuotePayload: Codable {
    var text: String
    var context: String?
    var source: String?
    var author: String?
    var tags: [String]?
}

enum ImportError: LocalizedError {
    case unsupportedType
    case malformedCSV(line: Int)
    case malformedJSON

    var errorDescription: String? {
        switch self {
        case .unsupportedType: "Only .csv and .json files are supported."
        case .malformedCSV(let line): "Could not parse line \(line) of the CSV."
        case .malformedJSON: "The JSON file was not an array of quote objects."
        }
    }
}

struct ImportExport {
    // MARK: - Import

    static func payloads(from url: URL) throws -> [QuotePayload] {
        let data = try Data(contentsOf: url)
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "json": return try decodeJSON(data: data)
        case "csv", "tsv", "txt": return try decodeCSV(data: data)
        default: throw ImportError.unsupportedType
        }
    }

    private static func decodeJSON(data: Data) throws -> [QuotePayload] {
        do {
            return try JSONDecoder().decode([QuotePayload].self, from: data)
        } catch {
            throw ImportError.malformedJSON
        }
    }

    private static func decodeCSV(data: Data) throws -> [QuotePayload] {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ImportError.malformedCSV(line: 0)
        }
        let rows = parseCSV(text)
        guard let header = rows.first else { return [] }
        let lower = header.map { $0.lowercased() }

        func column(_ names: String...) -> Int? {
            for n in names {
                if let idx = lower.firstIndex(of: n) { return idx }
            }
            return nil
        }

        let textIdx = column("text", "quote") ?? 0
        let contextIdx = column("context", "notes")
        let sourceIdx = column("source", "book")
        let authorIdx = column("author")
        let tagsIdx = column("tags")

        var payloads: [QuotePayload] = []
        for (lineNumber, row) in rows.dropFirst().enumerated() {
            guard row.indices.contains(textIdx) else {
                throw ImportError.malformedCSV(line: lineNumber + 2)
            }
            let tags = tagsIdx
                .flatMap { row.indices.contains($0) ? row[$0] : nil }?
                .split(whereSeparator: { $0 == ";" || $0 == "," })
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            payloads.append(QuotePayload(
                text: row[textIdx],
                context: contextIdx.flatMap { row.indices.contains($0) ? row[$0] : nil },
                source: sourceIdx.flatMap { row.indices.contains($0) ? row[$0] : nil },
                author: authorIdx.flatMap { row.indices.contains($0) ? row[$0] : nil },
                tags: tags
            ))
        }
        return payloads
    }

    /// RFC-4180-ish CSV parser: supports `"`-quoted fields and escaped `""`.
    static func parseCSV(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var field = ""
        var row: [String] = []
        var inQuotes = false
        var i = text.startIndex
        while i < text.endIndex {
            let ch = text[i]
            if inQuotes {
                if ch == "\"" {
                    let next = text.index(after: i)
                    if next < text.endIndex && text[next] == "\"" {
                        field.append("\"")
                        i = text.index(after: next)
                        continue
                    } else {
                        inQuotes = false
                    }
                } else {
                    field.append(ch)
                }
            } else {
                switch ch {
                case "\"": inQuotes = true
                case ",":
                    row.append(field); field = ""
                case "\n":
                    row.append(field); field = ""
                    rows.append(row); row = []
                case "\r":
                    break
                default:
                    field.append(ch)
                }
            }
            i = text.index(after: i)
        }
        if !field.isEmpty || !row.isEmpty {
            row.append(field)
            rows.append(row)
        }
        return rows.filter { !($0.count == 1 && $0[0].isEmpty) }
    }

    // MARK: - Insertion

    @discardableResult
    static func insert(
        payloads: [QuotePayload],
        into context: ModelContext
    ) -> Int {
        var tagCache: [String: Tag] = [:]
        var inserted = 0

        for payload in payloads {
            let trimmed = payload.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let tags = (payload.tags ?? []).map { name -> Tag in
                if let existing = tagCache[name.lowercased()] { return existing }
                let fetch = FetchDescriptor<Tag>(predicate: #Predicate { $0.name == name })
                if let existing = try? context.fetch(fetch).first {
                    tagCache[name.lowercased()] = existing
                    return existing
                }
                let tag = Tag(name: name)
                context.insert(tag)
                tagCache[name.lowercased()] = tag
                return tag
            }

            let quote = Quote(
                text: trimmed,
                context: payload.context ?? "",
                source: payload.source,
                author: payload.author,
                tags: tags
            )
            context.insert(quote)
            inserted += 1
        }
        return inserted
    }

    // MARK: - Export

    static func jsonExport(for quotes: [Quote]) throws -> Data {
        let payloads = quotes.map {
            QuotePayload(
                text: $0.text,
                context: $0.context.isEmpty ? nil : $0.context,
                source: $0.source,
                author: $0.author,
                tags: ($0.tags ?? []).map(\.name)
            )
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(payloads)
    }
}
