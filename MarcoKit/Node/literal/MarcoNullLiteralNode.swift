import Foundation

internal class MarcoNullLiteralNode : MarcoValueNode, MarcoNullLiteral {
    weak var parent: MarcoNode? = nil
    var offset: Int = 0
    
    init() {}
    
    var text: String {
        return "null"
    }
    
    func clone() -> MarcoNode {
        return MarcoNullLiteralNode()
    }
}

