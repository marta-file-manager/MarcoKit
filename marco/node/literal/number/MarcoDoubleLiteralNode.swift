import Foundation

internal class MarcoDoubleLiteralNode : MarcoValueNode, MarcoDoubleLiteral {
    weak var parent: MarcoNode? = nil
    var offset: Int = 0
    
    let text: String
    let doubleValue: Double
    
    init(text: String) {
        self.text = text
        self.doubleValue = Double(text) ?? 0
    }
    
    init(value: Double) {
        self.doubleValue = value
        self.text = String(value)
    }
    
    private init(text: String, value: Double) {
        self.doubleValue = value
        self.text = text
    }
    
    func clone() -> MarcoNode {
        return MarcoDoubleLiteralNode(text: text, value: doubleValue)
    }
}
