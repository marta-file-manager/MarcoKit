import Foundation
import XCTest
import MarcoKit

class ModificationTest : XCTestCaseWithTestData {
    func test() {
        test(groupName: "modification")
    }

    override func doTest(url: URL, testData: TestData) {
        let value = parse(url: url, content: testData.before).value
        do {
            try modify(value: value, testData: testData)
        } catch let e {
            fail(e.localizedDescription, url)
        }
        assertEquals(testData.after, value.text, url)
    }

    private func modify(value: MarcoValue, testData: TestData) throws {
        for modification in testData.modifications {
            let kind = modification.kind, data = modification.data, content = modification.content
            switch (kind) {
                case .add: applyAdd(value: value, data: data, valueToAdd: try Marco.parse(content).value)
                case .set: applySet(value: value, data: data, valueToSet: try Marco.parse(content).value)
                case .remove: applyRemove(value: value, data: data)
                case .get: applyGet(value: value, data: data, expected: content)
            }
        }
    }

    private func applyAdd(value: MarcoValue, data: [String], valueToAdd: MarcoValue) {
        let arrayTargetValue = getTargetValue(value, path: data)

        if let array = arrayTargetValue as? MarcoArray {
            array.add(valueToAdd)
        } else {
            let objectTargetValue = getTargetValue(value, path: Array(data.dropLast()), createIfMissing: true)
            if let object = objectTargetValue as? MarcoObject {
                let key = data.last!
                object[key] = valueToAdd
            } else {
                preconditionFailure("Error chunk kind, array or object expected")
            }
        }
    }
    
    private func applyGet(value: MarcoValue, data: [String], expected: String) {
        if let targetValue = getTargetValue(value, path: data) {
            XCTAssertEqual(expected, targetValue.text)
        } else {
            XCTAssertEqual(expected, "null")
        }
    }

    private func applyRemove(value: MarcoValue, data: [String]) {
        let targetValue = getTargetValue(value, path: Array(data.dropLast()))
        let key = data.last!

        if let array = targetValue as? MarcoArray {
            array.remove(at: Int(key)!)
        } else if let object = targetValue as? MarcoObject {
            object.remove(for: key)
        } else {
            preconditionFailure("Error chunk kind, array or object expected")
        }
    }

    private func applySet(value: MarcoValue, data: [String], valueToSet: MarcoValue) {
        let targetValue = getTargetValue(value, path: Array(data.dropLast()))
        let key = data.last!

        if let array = targetValue as? MarcoArray {
            array[Int(key)!] = valueToSet
        } else if let object = targetValue as? MarcoObject {
            object[key] = valueToSet
        } else {
            preconditionFailure("Error chunk kind, array or object expected")
        }
    }
    
    func getTargetValue(_ value: MarcoValue, path: Array<String>, createIfMissing: Bool = false) -> MarcoValue? {
        var current = value
        for chunk in path {
            if let array = current as? MarcoArray {
                current = array[Int(chunk)!]
            } else if let object = current as? MarcoObject {
                if let next = object[chunk] {
                    current = next
                } else if (createIfMissing) {
                    let newCurrent = Marco.emptyObject()
                    object[chunk] = newCurrent
                    current = newCurrent
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        return current
    }
}
