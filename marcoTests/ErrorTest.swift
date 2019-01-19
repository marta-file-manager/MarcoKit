import Foundation
import XCTest
import MarcoKit

class ErrorTest : XCTestCaseWithTestData {
    func test() {
        test(groupName: "error")
    }

    override func doTest(url: URL, testData: TestData) {
        do {
            _ = try tryParse(url: url, content: testData.before)
        } catch let e {
            if let e = e as? MarcoParsingError {
                assertEquals(testData.after, e.localizedDescription, url)
            } else if let e = e as? MarcoNonStrictParsingError {
                var text = e.document.text + "\n"
                for error in (e.errors) {
                    text += "\n" + String(error.offset) + ": " + error.message
                }
                assertEquals(testData.after, text, url)
            } else {
                assertEquals(testData.after, e.localizedDescription, url)
            }
            return
        }

        assertEquals(testData.after, "There were no parsing errors.", url)
    }
}
