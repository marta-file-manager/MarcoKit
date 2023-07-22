import Foundation

internal let HEX_SYMBOL_SET: Set<Character> = Set("0123456789ABCDEFabcdef")

internal class MarcoHexLiteralNode : MarcoValueNode, MarcoIntLiteral {
    weak var parent: MarcoNode? = nil
    var offset: Int = 0
    
    let text: String
    let intValue: Int
    
    var isColor: Bool {
        return false
    }
    
    init(text: String) {
        precondition(MarcoHexLiteralNode.checkSyntax(text: text))
        self.text = text
        self.intValue = MarcoHexLiteralNode.calculateValue(text: text)
    }
    
    private init(text: String, value: Int) {
        self.text = text
        self.intValue = value
    }
    
    private static func checkSyntax(text: String) -> Bool {
        guard text.count >= 3, text.first == "0" else { return false }
        
        let x = text[text.index(after: text.startIndex)]
        guard
            x == "X" || x == "x",
            (text.dropFirst(2).allSatisfy { HEX_SYMBOL_SET.contains($0) })
        else { return false }
        
        return true
    }
    
    private static func calculateValue(text: String) -> Int {
        let scanner = Scanner(string: text)
        scanner.currentIndex = text.index(text.startIndex, offsetBy: 2)

        let value = scanner.scanInt64(representation: .hexadecimal) ?? 0
        return Int(value)
    }
    
    func clone() -> MarcoNode {
        return MarcoHexLiteralNode(text: text, value: intValue)
    }
}
