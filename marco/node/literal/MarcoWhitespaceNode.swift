import Foundation

internal class MarcoWhitespaceNode : MarcoNode, CustomStringConvertible {
    weak var parent: MarcoNode? = nil
    var offset: Int = 0
    
    let text: String
    let containsNewLine: Bool
    
    init(text: String, containsNewLine: Bool) {
        self.text = text
        self.containsNewLine = containsNewLine
    }
    
    func clone() -> MarcoNode {
        return MarcoWhitespaceNode(text: text, containsNewLine: containsNewLine)
    }

    var description: String {
        return text
    }
}
