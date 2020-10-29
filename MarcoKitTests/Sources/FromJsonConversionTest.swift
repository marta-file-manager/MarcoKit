import Foundation
import XCTest
import MarcoKit

class FromJsonConversionTest : XCTestCaseWithTestData {
    func test() {
        test(groupName: "fromJson")
    }

    override func doTest(url: URL, testData: TestData) {
        let jsonObject = try! JSONSerialization.jsonObject(with: testData.before.data(using: .utf8)!)
        let rawMarco = fromJson(jsonObject, url: url)
        _ = try! tryParse(url: url, content: rawMarco.text)
        let prettifiedMarco = Marco.prettify(rawMarco)
        assertEquals(testData.after, prettifiedMarco.text, url)
    }
}
