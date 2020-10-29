import Foundation
import XCTest

class XCTestCaseWithTestData : XCTestCase {
    func doTest(url: URL, testData: TestData) {}

    func test(groupName: String) {
        let dirUrl = Bundle(for: ParseTest.self).resourceURL!.appendingPathComponent("TestData/" + groupName)
        for obj in FileManager.default.enumerator(at: dirUrl, includingPropertiesForKeys: nil)! {
            runSingleFile(url: obj as! URL)
        }
    }

    func test(groupName: String, testName: String) {
        let dirUrl = Bundle(for: ParseTest.self).resourceURL!.appendingPathComponent("TestData/" + groupName)
        for obj in FileManager.default.enumerator(at: dirUrl, includingPropertiesForKeys: nil)! {
            let url = obj as! URL
            guard (url.lastPathComponent as NSString).deletingPathExtension == testName else { continue }
            runSingleFile(url: url)
        }
    }

    private func runSingleFile(url: URL) {
        let ext = url.pathExtension
        guard ext == "marco" || ext == "marcoConfig" else { return }
        let content = try! String(contentsOf: url)
        let sections = parseSections(content: content)
        guard (sections.contains { $0.name == "before" }) else {
            fail("'before' section not found", url)
            return
        }
        let testData = parseTestData(sections: parseSections(content: content))
        doTest(url: url, testData: testData)
    }

    private func parseSections(content: String) -> [Section] {
        var sections = [Section]()
        var name = "", sectionData = "", sectionContent = ""

        func saveCurrentSection() {
            guard !name.isEmpty else { return }
            let prettyContent = sectionContent.trimmingCharacters(in: .whitespacesAndNewlines)
            sections.append(Section(name: name, data: sectionData, content: prettyContent))
            name = ""
            sectionData = ""
            sectionContent = ""
        }

        content.enumerateLines { line, _ in
            if (line.hasPrefix("--")) {
                saveCurrentSection()

                let splits = line.dropFirst(2).split(separator: " ", maxSplits: 1).map { String($0) }
                name = String(splits[0])
                sectionData = splits.count == 2 ? String(splits[1]) : ""

                return
            }

            if (!sectionContent.isEmpty) {
                sectionContent += "\n"
            }

            sectionContent += line
        }

        saveCurrentSection()
        return sections
    }

    private func parseTestData(sections: [Section]) -> TestData {
        let before = sections.first { $0.name == "before" }!.content
        let after = sections.first { $0.name == "after" }?.content ?? ""

        let modifications: [Modification] = sections
            .filter { s in s.name != "before" && s.name != "after" }
            .map { s in
                let kind = Modification.Kind.parse(s.name)
                let data = s.data.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                return Modification(kind: kind, data: data, content: s.content)
            }

        return TestData(before: before, after: after, modifications: modifications)
    }
}

fileprivate class Section {
    let name: String
    let data: String
    let content: String

    init(name: String, data: String, content: String) {
        self.name = name
        self.data = data
        self.content = content
    }
}

class TestData {
    let before: String
    let after: String
    let modifications: [Modification]

    init(before: String, after: String, modifications: [Modification]) {
        self.before = before
        self.after = after
        self.modifications = modifications
    }
}

class Modification {
    enum Kind {
        case add, remove, set, get
    }

    let kind: Kind
    let data: [String]
    let content: String

    init(kind: Kind, data: [String], content: String) {
        self.kind = kind
        self.data = data
        self.content = content
    }
}

fileprivate extension Modification.Kind {
    static func parse(_ name: String) -> Modification.Kind {
        switch (name) {
            case "add": return .add
            case "remove": return .remove
            case "set": return .set
            case "get": return .get
            default: preconditionFailure("Unexpected modification kind \(name)")
        }
    }
}
