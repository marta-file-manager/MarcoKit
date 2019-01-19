import Foundation

internal let is64BitPlatform = Int64(Int.max) == Int64.max

internal class MarcoParser {
    private static let HEX_NUMBER_SYMBOLS = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
    private static let DEC_NUMBER_SYMBOLS = CharacterSet(charactersIn: "0123456789.eE+-")
    private static let ESCAPABLE_SYMBOLS = CharacterSet(charactersIn: "ntr\"\\u")
    
    private static let IDENTIFIER_START = CharacterSet.letters.union(CharacterSet(charactersIn: "$_"))
    private static let IDENTIFIER_MAIN = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "$_."))

    private let state: MarcoParserState
    private let options: Marco.Options

    private var isParsed: Bool = false

    static func parse(text: String, options: Marco.Options = []) throws -> MarcoDocument {
        return try MarcoParser(text: text, options: options).parse()
    }
    
    private init(text: String, options: Marco.Options) {
        state = MarcoParserState(text: text)
        self.options = options
    }

    private func parse() throws -> MarcoDocumentNode {
        precondition(!isParsed)
        isParsed = true

        let document: MarcoDocumentNode

        if (options.contains(.config)) {
            let object = try parseObject(withBrackets: false)
            document = MarcoDocumentNode(children: [object], valueIndex: 0)
        } else {
            var children = [MarcoNode]()
            children.appendIfNotNull(try parseWhitespace())

            let valueIndex = children.isEmpty ? 0 : 1

            children.append(try parseValue())
            children.appendIfNotNull(try parseWhitespace())

            document = MarcoDocumentNode(children: children, valueIndex: valueIndex)
        }

        guard state.isEof else { throw state.unexpectedCharacter(title: "End of file expected, got") }

        if (!state.recordedErrors.isEmpty) {
            throw MarcoNonStrictParsingError(errors: state.recordedErrors, document: document)
        }

        return document
    }

    static func isSimpleKey(key: String) -> Bool {
        precondition(!key.isEmpty)
        return key[key.startIndex].matches(IDENTIFIER_START)
            && key.dropFirst().allSatisfy { $0.matches(IDENTIFIER_MAIN) }
    }
    
    private func parseValue() throws -> MarcoValueNode {
        let current = try state.current()
        
        switch (current) {
            case MarcoStructuralElementNode.Kind.leftCurlyBracket.rawValue: return try parseObject()
            case MarcoStructuralElementNode.Kind.leftSquareBracket.rawValue: return try parseArray()
            case "t", "f": return try parseBoolLiteral()
            case "n": return try parseNullLiteral()
            case "\"": return try parseStringLiteral()
            case "-", "#", "0"..."9": return try parseNumberLiteral()
            default: throw state.unexpectedCharacter(title: "Unexpected value character")
        }
    }
    
    private func parseArray() throws -> MarcoArrayNode {
        try state.match(MarcoStructuralElementNode.Kind.leftSquareBracket.rawValue)
        
        var children: [MarcoNode] = [MarcoStructuralElementNode(.leftSquareBracket)]
        var elementIndices = [Int]()
        
        while (true) {
            let whitespace = try parseWhitespace()
            children.appendIfNotNull(whitespace)

            guard try !parseCommaSeparatorIfPresent(&children) else { continue }

            guard try parseStructuralIfPresent(.rightSquareBracket, &children) else { break }

            if (whitespace == nil && !elementIndices.isEmpty) {
                try throwOrRecord(state.error("Whitespace required between array entries"))
            }

            let ignoreValue = try !parseStructuralIfPresent(.ignoring, &children)
            let element = try parseValue()
            
            if (!ignoreValue) {
                elementIndices.append(children.count)
            }
            
            children.append(element)
        }
        
        return MarcoArrayNode(children: children, elementIndices: elementIndices)
    }

    private func parseObject(withBrackets: Bool = true) throws -> MarcoObjectNode {
        var children = [MarcoNode]()
        
        if (withBrackets) {
            try state.match(MarcoStructuralElementNode.Kind.leftCurlyBracket.rawValue)
            children.append(MarcoStructuralElementNode(.leftCurlyBracket))
        }
        
        var keyMappings = [String: Int]()

        while (true) {
            let whitespaceBeforeKey = try parseWhitespace()
            children.appendIfNotNull(whitespaceBeforeKey)
            
            if (state.isEof) {
                if (withBrackets) {
                    try throwOrRecord(state.error("'}' expected"))
                }
                break
            }

            guard try !parseCommaSeparatorIfPresent(&children) else { continue }

            guard try parseStructuralIfPresent(.rightCurlyBracket, &children) else { break }

            if (whitespaceBeforeKey == nil && !keyMappings.isEmpty) {
                try throwOrRecord(state.error("Whitespace required between object entries"))
            }

            let isIgnored = try !parseStructuralIfPresent(.ignoring, &children)
            
            /* parseKeyValuePair */ do {
                var keyValuePairChildren = [MarcoNode]()

                let indexBeforeKey = state.index
                let key = try parseKey()

                if (!isIgnored && keyMappings[key.value] != nil) {
                    try throwOrRecord(state.error("Duplicating key '\(key.value)'", index: indexBeforeKey))
                }

                keyValuePairChildren.append(key)
                
                let whitespaceAfterKey = try parseWhitespace()
                var whitespacePresent = whitespaceAfterKey != nil

                keyValuePairChildren.appendIfNotNull(whitespaceAfterKey)

                if (try parseColonOrEqualsIfPresent(&keyValuePairChildren)) {
                    let whitespaceAfterColonOrEquals = try parseWhitespace()
                    if (!whitespacePresent && whitespaceAfterColonOrEquals != nil) {
                        whitespacePresent = true
                    }

                    keyValuePairChildren.appendIfNotNull(whitespaceAfterColonOrEquals)
                }

                let indexBeforeValue = state.index
                let value = try parseValue()

                if (!whitespacePresent) {
                    try throwOrRecord(state.error("Whitespace required in a key-value pair", index: indexBeforeValue))
                }

                let valueIndex = keyValuePairChildren.count
                keyValuePairChildren.append(value)
                
                if (!isIgnored) {
                    keyMappings[key.value] = children.count
                }
                
                children.append(MarcoKeyValuePairNode(
                    children: keyValuePairChildren, keyIndex: 0, valueIndex: valueIndex))
            }
        }

        return MarcoObjectNode(children: children, keyMappings: keyMappings, isConfig: !withBrackets)
    }

    private func parseCommaSeparatorIfPresent(_ children: inout [MarcoNode]) throws -> Bool {
        guard options.contains(.nonStrict) && state.currentOrNull() == "," else { return false }
        state.record(error: state.error("Invalid character: Marco does not use ',' as a separator"))
        children.append(WS(String(try state.advance())))
        return true
    }

    private func parseColonOrEqualsIfPresent(_ children: inout [MarcoNode]) throws -> Bool {
        guard options.contains(.nonStrict) else { return false }
        guard let current = state.currentOrNull(), current == "=" || current == ":" else { return false }
        state.record(error: state.error("Invalid character: Marco does not use '\(current)' as a separator"))
        children.append(WS(String(try state.advance())))
        return true
    }

    private func parseStructuralIfPresent(
        _ char: MarcoStructuralElementNode.Kind,
        _ children: inout [MarcoNode]
    ) throws -> Bool {
        let current = try state.current()
        if (current == char.rawValue) {
            try state.skip()
            children.append(MarcoStructuralElementNode(char))
            return false
        }

        return true
    }

    private func parseKey() throws -> MarcoIdentifierLikeNode {
        let current = try state.current()

        if (current == "\"") {
            return try parseStringLiteral()
        } else {
            return try parseIdentifier()
        }
    }
    
    private func parseIdentifier() throws -> MarcoIdentifierNode {
        let startIndex = state.index
        let first = try state.advance()
        guard first.matches(MarcoParser.IDENTIFIER_START) else {
            throw state.unexpectedCharacter(title: "Unexpected identifier character", index: startIndex)
        }
        
        var text = String(first)
        
        while let current = state.currentOrNull(), current.matches(MarcoParser.IDENTIFIER_MAIN) {
            text.append(try state.advance())
        }
        
        return MarcoIdentifierNode(name: text)
    }

    private func parseWhitespace() throws -> MarcoWhitespaceNode? {
        var text = ""
        var containsNewLine = false
        
        while let current = state.currentOrNull() {
            if (current == "\n") {
                text.append(try state.advance())
                containsNewLine = true
            } else if (current == " " || current == "\t" || current == "\r") {
                text.append(try state.advance())
            } else {
                break
            }
        }
        
        guard !text.isEmpty else { return nil }
        return MarcoWhitespaceNode(text: text, containsNewLine: containsNewLine)
    }

    private func parseNullLiteral() throws -> MarcoNullLiteralNode {
        try state.match("null")
        return MarcoNullLiteralNode()
    }
    
    private func parseBoolLiteral() throws -> MarcoBoolLiteralNode {
        let current = try state.current()
        
        if (current == "t") {
            try state.match("true")
            return MarcoBoolLiteralNode(value: true)
        } else if (current == "f") {
            try state.match("false")
            return MarcoBoolLiteralNode(value: false)
        } else {
            throw state.error("Boolean literal expected")
        }
    }
    
    private func parseNumberLiteral() throws -> MarcoValueNode {
        var text: String = ""

        let probSign = try state.current()
        if (probSign == "+" || probSign == "-") {
            text.append(try state.advance())
        }
        
        let firstChar = try state.advance()
        text.append(firstChar)
        
        func parseHex(maxLength: Int = Int.max) throws -> Int {
            var parsedCount = 0
            while let current = state.currentOrNull(),
                current.matches(MarcoParser.HEX_NUMBER_SYMBOLS) && text.count <= maxLength
            {
                text.append(try state.advance())
                parsedCount += 1
            }
            
            return parsedCount
        }
        
        if (firstChar == "#") {
            let parsedCount = try parseHex(maxLength: 8)
            if (parsedCount != 3 && parsedCount != 6 && parsedCount != 8) {
                throw state.unexpectedCharacter(title: "Color literal expected, got")
            }
            
            return MarcoColorLiteralNode(text: text)
        } else if (firstChar == "0") {
            let probNext = state.currentOrNull()
            if (probNext == "x" || probNext == "X") {
                text.append(try state.advance())
                _ = try parseHex()
                return MarcoHexLiteralNode(text: text)
            }
        }
        
        var isDouble = false
        while let current = state.currentOrNull(), current.matches(MarcoParser.DEC_NUMBER_SYMBOLS) {
            let currentIndex = state.index
            text.append(try state.advance())

            if (current == ".") {
                if (isDouble) {
                    try throwOrRecord(state.error("Duplicating '.' in a number literal", index: currentIndex))
                } else {
                    isDouble = true
                }
            }
        }
        
        return isDouble ? MarcoDoubleLiteralNode(text: text) : MarcoIntLiteralNode(text: text)
    }
    
    private func parseStringLiteral() throws -> MarcoStringLiteralNode {
        try state.match("\"")
        
        var text = "\""
        
        while (true) {
            let current = try state.advance()
            
            if (current == "\"") {
                text.append(current)
                break
            } else if (current == "\\") {
                let escaped = try state.advance()
                if (!escaped.matches(MarcoParser.ESCAPABLE_SYMBOLS)) {
                    try throwOrRecord(state.error(
                        "Illegal escaped characters. Only \\n, \\t, \\r, \\\", \\\\ and \\uXXXX are supported."))
                }
                text.append(current)
                text.append(escaped)
                if (escaped == "u") {
                    for _ in 1...4 {
                        let unicodeNumber = try state.advance()
                        if (!unicodeNumber.matches(MarcoParser.HEX_NUMBER_SYMBOLS)) {
                            throw state.error("Invalid unicode character")
                        }
                        text.append(unicodeNumber)
                    }
                }
            } else {
                text.append(current)
            }
        }
        
        return MarcoStringLiteralNode(text: text)
    }

    private func throwOrRecord(_ error: MarcoParsingError) throws {
        if (options.contains(.nonStrict)) {
            state.record(error: error)
        } else {
            throw error
        }
    }
}

fileprivate extension Array {
    mutating func appendIfNotNull(_ element: Element?) {
        if let el = element {
            self.append(el)
        }
    }
}

fileprivate extension Character {
    func matches(_ set: CharacterSet) -> Bool {
        for scalar in self.unicodeScalars {
            guard set.contains(scalar) else { return false }
        }
        return true
    }
}
