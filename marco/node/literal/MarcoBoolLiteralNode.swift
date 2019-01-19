import Foundation

internal class MarcoBoolLiteralNode : MarcoValueNode, MarcoBoolLiteral {
    weak var parent: MarcoNode? = nil
    var offset: Int = 0
    
    let value: Bool
    
    init(value: Bool) {
        self.value = value
    }
    
    var text: String {
        return value ? "true" : "false"
    }
    
    func clone() -> MarcoNode {
        return MarcoBoolLiteralNode(value: value)
    }
}
