import Foundation

internal class MarcoStringLiteralNode : MarcoValueNode, MarcoStringLiteral, MarcoIdentifierLikeNode {
    weak var parent: MarcoNode? = nil
    var offset: Int = 0
    
    let text: String
    let value: String
    
    init(text: String) {
        self.text = text
        self.value = MarcoStringLiteralNode.calculateValue(text: text)
    }
    
    init(value: String) {
        self.value = value
        self.text = MarcoStringLiteralNode.calculateText(value: value)
    }
    
    private init(text: String, value: String) {
        self.text = text
        self.value = value
    }
    
    private static func calculateValue(text: String) -> String {
        precondition(text.first == "\"" && text.last == "\"")

        var value: String = ""
        var iterator = text.dropFirst().dropLast().makeIterator()

        while let current = iterator.next() {
            if (current == "\"") {
                preconditionFailure("Unexpected '\"' in String literal \(text)")
            } else if (current == "\\") {
                guard let escaped = iterator.next() else {
                    preconditionFailure("Unexpected escaped character in String literal \(text)")
                }
                switch (escaped) {
                    case "\"": value.append("\"")
                    case "\\": value.append("\\")
                    case "n": value.append("\n")
                    case "t": value.append("\t")
                    case "r": value.append("\r")
                    case "u":
                        let chars = String([iterator.next()!, iterator.next()!, iterator.next()!, iterator.next()!])
                        guard let hex = Int(chars, radix: 16) else { preconditionFailure("Invalid hex literal: \(chars)") }
                        guard let scalar = UnicodeScalar(hex) else { preconditionFailure("Invalid scalar: \(chars)") }
                        value.append(Character(scalar))
                    default: value.append(escaped)
                }
            } else {
                value.append(current)
            }
        }
        
        return value
    }

    private static func calculateText(value: String) -> String {
        var text: String = "\""
        
        for char in value {
            switch (char) {
                case "\"": text.append("\\\"")
                case "\\": text.append("\\\\")
                case "\n": text.append("\\n")
                case "\t": text.append("\\t")
                case "\r": text.append("\\r")
                default:
                    let scalars = char.unicodeScalars
                    if scalars.count == 1, let scalar = scalars.first, scalar.isASCII && scalar.value < 32 {
                        text.append("\\u" + getScalarString(scalar: scalar))
                    } else {
                        text.append(char)
                    }
            }
        }
        
        return text + "\""
    }

    private static func getScalarString(scalar: UnicodeScalar) -> String {
        let rawText = String(scalar.value, radix: 16, uppercase: true)
        precondition(rawText.count <= 4)
        if (rawText.count < 4) {
            return String(repeating: "0", count: 4 - rawText.count) + rawText
        } else {
            return rawText
        }
    }
    
    func clone() -> MarcoNode {
        return MarcoStringLiteralNode(text: text, value: value)
    }
}
