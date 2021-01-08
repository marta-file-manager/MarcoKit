import Foundation

internal class MarcoParserState {
    private let text: String
    private let showContextInErrors: Bool

    private(set) var index: String.Index

    private(set) var recordedErrors = [MarcoParsingError]()

    init(text: String, showContextInErrors: Bool) {
        self.text = text
        self.showContextInErrors = showContextInErrors

        self.index = self.text.startIndex
    }

    var isEof: Bool {
        return index == text.endIndex
    }

    func advance() throws -> Character {
        try checkIndex()
        let ch = text[index]
        index = text.index(after: index)
        return ch
    }
    
    func current() throws -> Character {
        try checkIndex()
        return text[index]
    }
    
    func currentOrNull() -> Character? {
        guard !isEof else { return nil }
        return text[index]
    }

    func record(error: MarcoParsingError) {
        recordedErrors.append(error)
    }

    private func checkIndex() throws {
        guard !isEof else {
            let lineRange = text.lineRange(for: lastCharacterRange())
            throw error("Unexpected end of file", range: lineRange)
        }
    }
}

internal extension MarcoParserState {
    func skip() throws {
        _ = try advance()
    }

    func match(_ char: Character) throws {
        let indexBefore = self.index
        if ((try advance()) != char) {
            throw unexpectedCharacter(expected: char, range: indexBefore..<self.index)
        }
    }

    func match(_ word: String) throws {
        let indexBefore = self.index

        do {
            for char in word {
                try match(char)
            }
        } catch _ {
            throw self.error("'\(word)' expected", range: indexBefore..<self.index)
        }
    }

    private func lastCharacterRange() -> Range<String.Index> {
        guard !text.isEmpty else { return text.startIndex..<text.endIndex }

        if index == text.endIndex {
            return text.index(before: index)..<index
        } else {
            return index..<text.index(after: index)
        }
    }
    
    func unexpectedCharacter(
        title: String = "Unexpected character",
        expected: Character? = nil,
        range: Range<String.Index>? = nil
    ) -> MarcoParsingError {
        let actual: String
        if let char = currentOrNull() {
            switch (char) {
                case "\n": actual = "\\n"
                case "\r": actual = "\\r"
                case "\t": actual = "\\t"
                default: actual = String(char)
            }
        } else {
            actual = "<eof>"
        }
        
        var message = "\(title) '\(actual)'"
        if let char = expected {
            message.append(", expected '\(char)'")
        }
        
        return error(message, range: range ?? lastCharacterRange())
    }

    func error(_ message: String) -> MarcoParsingError {
        return MarcoParsingError(message: message, range: lastCharacterRange())
    }

    func error(_ message: String, indexBefore: String.Index) -> MarcoParsingError {
        return MarcoParsingError(message: message, range: indexBefore..<self.index)
    }
    
    func error(_ message: String, range: Range<String.Index>) -> MarcoParsingError {
        return MarcoParsingError(message: message, range: range)
    }
}
