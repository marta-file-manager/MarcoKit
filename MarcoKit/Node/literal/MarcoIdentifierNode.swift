import Foundation

internal class MarcoIdentifierNode : MarcoIdentifierLikeNode, CustomStringConvertible {
    weak var parent: MarcoNode? = nil
    var offset: Int = 0
    
    let value: String

    var text: String {
        return value
    }
    
    init(name: String) {
        self.value = name
    }
    
    func clone() -> MarcoNode {
        return MarcoIdentifierNode(name: value)
    }

    var description: String {
        return text
    }
}