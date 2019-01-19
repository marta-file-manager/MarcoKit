import Foundation

internal class MarcoStructuralElementNode : MarcoNode, CustomStringConvertible {
    weak var parent: MarcoNode? = nil
    var offset: Int = 0
    
    let kind: Kind
    
    init(_ kind: Kind) {
        self.kind = kind
    }
    
    var text: String {
        return String(kind.rawValue)
    }
    
    enum Kind : Character {
        case leftSquareBracket = "[", rightSquareBracket = "]",
             leftCurlyBracket = "{", rightCurlyBracket = "}",
             ignoring = "!"
    }
    
    func clone() -> MarcoNode {
        return MarcoStructuralElementNode(kind)
    }

    var description: String {
        return text
    }
}