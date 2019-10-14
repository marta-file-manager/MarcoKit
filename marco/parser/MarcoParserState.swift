import Foundation

internal class MarcoParserState {
    private let text: String
    private let showContextInErrors: Bool

    private(set) var index: String.Index

    private(set) var recordedErrors = [MarcoParsingError]()

    func getPos(index: String.Index) -> Int {
        if text.endIndex == index {
            return text.count
        }
        return text.distance(from: text.startIndex, to: index)
    }
    
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
        guard !isEof else { throw error("Unexpected end of file") }
    }
}

internal extension MarcoParserState {
    func skip() throws {
        _ = try advance()
    }

    func match(_ char: Character) throws {
        let index = self.index
        if ((try advance()) != char) {
            throw unexpectedCharacter(expected: char, index: index)
        }
    }

    func match(_ word: String) throws {
        do {
            for char in word {
                try match(char)
            }
        } catch _ {
            throw self.error("'\(word)' expected")
        }
    }
    
    func unexpectedCharacter(
        title: String = "Unexpected character",
        expected: Character? = nil,
        index: String.Index? = nil
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
        
        return error(message, index: index ?? self.index)
    }
    
    func error(_ message: String) -> MarcoParsingError {
        return error(message, index: index)
    }
    
    func error(
        _ message: String,
        index: String.Index,
        kind: MarcoParsingError.ErrorKind = .unknown
    ) -> MarcoParsingError {
        let pos = getPos(index: index)

        let context: String
        if showContextInErrors && pos > 0 {
            context = text[..<index].suffix(100) + "💥"
        } else {
            context = ""
        }
        
        return MarcoParsingError(kind: kind, offset: pos, message: message, context: context)
    }
}
