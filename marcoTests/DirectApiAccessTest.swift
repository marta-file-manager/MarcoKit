import Foundation
import XCTest
import MarcoKit

class DirectApiAccessTest: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    private func testHelloWorld(document: MarcoDocument) {
        XCTAssert(document.value is MarcoObject)
        let outerObject = document.value as! MarcoObject
        XCTAssert(outerObject.count == 1)

        let helloValue = outerObject["hello"]
        XCTAssert(helloValue is MarcoObject)
        let helloObject = helloValue as! MarcoObject
        XCTAssert(helloObject.count == 1)

        let worldValue = helloObject["world"]
        XCTAssert(worldValue is MarcoStringLiteral)
        XCTAssert((worldValue as! MarcoStringLiteral).value == "x")

        let worldValue2 = outerObject["hello", "world"]
        XCTAssert((worldValue2 as? MarcoStringLiteral)?.value == "x")
    }

    func testHelloWorld() {
        let document = try! Marco.parse("""
        { hello { world "x" } }
        """)

        testHelloWorld(document: document)
    }

    func testHelloWorldConfig() {
        let document = try! Marco.parse("""
        hello { world "x" }
        """, options: .config)

        testHelloWorld(document: document)
    }
    
    func testArrayAsSequence() {
        let document = try! Marco.parse("[1 2 3]")
        let arr = document.value as! MarcoArray
        let max = arr.sequence().map { ($0 as! MarcoIntLiteral).intValue }.max()
        XCTAssertEqual(3, max)
    }

    func testSpecialChars() {
        let document = try! Marco.parse("\"\\t\\r\\n\\u0041\"")
        let str = document.value.asString!
        XCTAssertEqual("\t\r\nA", str)
    }
}
