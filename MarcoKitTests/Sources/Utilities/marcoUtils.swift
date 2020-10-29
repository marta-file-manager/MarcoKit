import Foundation
import XCTest
import MarcoKit

func parse(url: URL, content: String) -> MarcoDocument {
    do {
        return try tryParse(url: url, content: content)
    } catch let e {
        fail(e.localizedDescription, url)
        preconditionFailure("Test crashed.")
    }
}

func tryParse(url: URL, content: String) throws -> MarcoDocument {
    var options: Marco.Options = [.showContextInErrors]

    if (url.pathExtension == "marcoConfig") {
        options.insert(.config)
    }

    if (url.lastPathComponent.contains("NonStrict")) {
        options.insert(.nonStrict)
    }

    return try Marco.parse(content, options: options)
}

func fromJson(_ obj: Any, url: URL) -> MarcoDocument {
    let isConfig = url.pathExtension == "marcoConfig"
    if (isConfig) {
        return Marco.configFromJson(object: obj as! [String: Any])
    } else {
        return Marco.fromJson(object: obj)
    }
}
