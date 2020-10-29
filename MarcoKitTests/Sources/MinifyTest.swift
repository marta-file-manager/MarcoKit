import Foundation
import XCTest
import MarcoKit

class MinifyTest : XCTestCaseWithTestData {
    func test() {
        test(groupName: "minify")
    }

    override func doTest(url: URL, testData: TestData) {
        let value = parse(url: url, content: testData.before)
        assertEquals(testData.after, Marco.minify(value).text, url)
    }
}
