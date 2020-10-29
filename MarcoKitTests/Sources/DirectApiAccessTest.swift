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

    func testNewObject() {
        let obj = Marco.object(("foo", 1.toMarco), ("bar", 2.toMarco), ("baz", 3.toMarco))
        XCTAssertEqual(3, obj["baz"]?.asInt ?? 0)
    }

    func testNewArray() {
        let arr = Marco.array(1.toMarco, 2.toMarco, 3.toMarco)
        XCTAssertEqual(3, arr[2].asIntOrZero)
    }

    func testSpecialChars() {
        let document = try! Marco.parse("\"\\t\\r\\n\\u0041\"")
        let str = document.value.asString!
        XCTAssertEqual("\t\r\nA", str)
    }

    func testAdding() {
        let obj = Marco.object(("foo", 1.toMarco), ("bar", 2.toMarco), ("baz", 3.toMarco))
        obj["boo"] = "foo".toMarco
        let text = Marco.prettify(obj, reorderKeys: false).text
        XCTAssertEqual("{\n    foo 1\n    bar 2\n    baz 3\n    boo \"foo\"\n}", text)
    }
}
