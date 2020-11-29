import Foundation
import XCTest
import MarcoKit

class ErrorTest : XCTestCaseWithTestData {
    func test() {
        test(groupName: "error")
    }

    override func doTest(url: URL, testData: TestData) {
        let documentText = testData.before

        func render(error: MarcoParsingError) -> String {
            let offset = documentText.distance(from: documentText.startIndex, to: error.index)
            return String(offset) + ": " + error.message
        }

        do {
            _ = try tryParse(url: url, content: documentText)
        } catch let e {
            if let e = e as? MarcoParsingError {
                assertEquals(testData.after, render(error: e), url)
            } else if let e = e as? MarcoNonStrictParsingError {
                var text = e.document.text + "\n"
                e.errors.forEach { text += "\n" + render(error: $0) }
                assertEquals(testData.after, text, url)
            } else {
                assertEquals(testData.after, e.localizedDescription, url)
            }
            return
        }

        assertEquals(testData.after, "There were no parsing errors.", url)
    }
}
