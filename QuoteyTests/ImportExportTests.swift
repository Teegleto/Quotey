import XCTest
@testable import Quotey

final class ImportExportTests: XCTestCase {
    func testSimpleCSV() {
        let csv = """
        text,context,author,tags
        "Know thyself.","Inscription at Delphi.",Socrates,"philosophy;greece"
        """
        let rows = ImportExport.parseCSV(csv)
        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows[1][0], "Know thyself.")
        XCTAssertEqual(rows[1][1], "Inscription at Delphi.")
        XCTAssertEqual(rows[1][2], "Socrates")
        XCTAssertEqual(rows[1][3], "philosophy;greece")
    }

    func testCSVWithEscapedQuotes() {
        let csv = """
        text
        "She said ""hello""."
        """
        let rows = ImportExport.parseCSV(csv)
        XCTAssertEqual(rows[1][0], "She said \"hello\".")
    }

    func testPayloadsFromCSVFile() throws {
        let csv = """
        text,context,source,author,tags
        "One.","First context.",Book,Alice,"tag1;tag2"
        "Two.",,,,tag1
        """
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("q-\(UUID()).csv")
        try csv.data(using: .utf8)!.write(to: tmp)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let payloads = try ImportExport.payloads(from: tmp)
        XCTAssertEqual(payloads.count, 2)
        XCTAssertEqual(payloads[0].text, "One.")
        XCTAssertEqual(payloads[0].tags, ["tag1", "tag2"])
        XCTAssertEqual(payloads[1].text, "Two.")
        XCTAssertEqual(payloads[1].tags, ["tag1"])
    }

    func testPayloadsFromJSONFile() throws {
        let json = """
        [
          {"text":"A.","author":"X","tags":["t1"]},
          {"text":"B.","context":"c"}
        ]
        """
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("q-\(UUID()).json")
        try json.data(using: .utf8)!.write(to: tmp)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let payloads = try ImportExport.payloads(from: tmp)
        XCTAssertEqual(payloads.count, 2)
        XCTAssertEqual(payloads[0].tags, ["t1"])
        XCTAssertEqual(payloads[1].context, "c")
    }
}
