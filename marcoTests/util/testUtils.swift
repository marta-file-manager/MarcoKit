import Foundation
import XCTest

func assertNoThrow<T : Any>(block: () throws -> T) -> T {
    var result: T? = nil
    XCTAssertNoThrow(try {
        result = try block()
    }())
    return result!
}

func assertEquals<T : Equatable>(_ expected: T, _ actual: T, _ url: URL) {
    guard expected != actual else { return }
    let text = "\nExpected (\(url.relativePath)):\n\(expected)\n\nActual:\n\(actual)"
    XCTFail(text)
}

func fail(_ message: String, _ url: URL) {
    let text = url.relativePath + "\n" + message
    XCTFail(text)
}

fileprivate class TestObj {}

fileprivate extension URL {
    var relativePath: String {
        let selfPath = self.path
        let resourcesPath = Bundle(for: TestObj.self).resourceURL!.path
        precondition(self.path.hasPrefix(resourcesPath + "/"))
        return String(selfPath.dropFirst(resourcesPath.count + 1))
    }
}
