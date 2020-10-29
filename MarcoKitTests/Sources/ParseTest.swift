import Foundation
import XCTest
import MarcoKit

class ParseTest : XCTestCaseWithTestData {
    func test() {
        test(groupName: "parse")
    }

    override func doTest(url: URL, testData: TestData) {
        let value = parse(url: url, content: testData.before)
        assertEquals(testData.before, value.text, url)
    }
}
