import Foundation
import XCTest
import MarcoKit

class PrettifyTest : XCTestCaseWithTestData {
    func test() {
        test(groupName: "prettify")
    }

    override func doTest(url: URL, testData: TestData) {
        let value: MarcoDocument = parse(url: url, content: testData.before)
        assertEquals(testData.after, Marco.prettify(value).text, url)
    }
}
