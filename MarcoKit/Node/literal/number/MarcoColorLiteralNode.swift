import Foundation

internal class MarcoColorLiteralNode : MarcoValueNode, MarcoIntLiteral {
    weak var parent: MarcoNode? = nil
    var offset: Int = 0
    
    let text: String
    let intValue: Int
    let useAlpha: Bool
    
    var isColor: Bool {
        return true
    }
    
    init(text: String) {
        precondition(MarcoColorLiteralNode.checkSyntax(text: text))
        self.text = text
        (intValue, useAlpha) = MarcoColorLiteralNode.calculateValue(text: text)
    }
    
    private init(text: String, value: Int, useAlpha: Bool) {
        self.text = text
        self.intValue = value
        self.useAlpha = useAlpha
    }
    
    private static func checkSyntax(text: String) -> Bool {
        guard text.count == 4 || text.count == 7 || text.count == 9 else { return false }
        guard text[text.startIndex] == "#" else { return false }
        guard (text.dropFirst().allSatisfy { HEX_SYMBOL_SET.contains($0) }) else { return false }
        return true
    }
    
    private static func calculateValue(text: String) -> (Int, Bool) {
        if (text.count == 4) {
            var full = String(text[text.startIndex])
            for ch in text.dropFirst() {
                full.append(ch)
                full.append(ch)
            }
            return MarcoColorLiteralNode.calculateValue(text: full)
        }

        let useAlpha = text.count == 9
        let scanner = Scanner(string: text)
        scanner.currentIndex = text.index(after: text.startIndex)
        
        let value = scanner.scanUInt64(representation: .hexadecimal) ?? 0
        return (Int(value), useAlpha)
    }
    
    func clone() -> MarcoNode {
        return MarcoColorLiteralNode(text: text, value: intValue, useAlpha: useAlpha)
    }
}
