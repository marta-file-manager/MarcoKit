import Foundation

internal class MarcoIntLiteralNode : MarcoValueNode, MarcoIntLiteral {
    weak var parent: MarcoNode? = nil
    var offset: Int = 0
    
    let text: String
    let intValue: Int
    
    var isColor: Bool {
        return false
    }
    
    init(text: String) {
        self.text = text
        self.intValue = Int(text) ?? 0
    }
    
    init(value: Int) {
        self.intValue = value
        self.text = String(intValue)
    }
    
    private init(text: String, value: Int) {
        self.text = text
        self.intValue = value
    }
    
    func clone() -> MarcoNode {
        return MarcoIntLiteralNode(text: text, value: intValue)
    }
}
