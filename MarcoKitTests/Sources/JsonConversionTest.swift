import Foundation
import XCTest
import MarcoKit

class JsonConversionTest : XCTestCaseWithTestData {
    func test() {
        test(groupName: "json")
    }

    override func doTest(url: URL, testData: TestData) {
        let value = Marco.prettify(parse(url: url, content: testData.before))
        let jsonString = Marco.toJsonString(value)
        let jsonObject = try! JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!)
        let rawMarco = fromJson(jsonObject, url: url)
        _ = try! tryParse(url: url, content: rawMarco.text)
        let prettifiedMarco = Marco.prettify(rawMarco)
        let actual = (jsonString + "\n\n" + prettifiedMarco.text).trimmingCharacters(in: .whitespacesAndNewlines)
        assertEquals(testData.after, actual, url)
    }
}
