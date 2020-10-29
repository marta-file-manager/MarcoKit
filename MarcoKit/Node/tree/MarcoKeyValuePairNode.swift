import Foundation

internal class MarcoKeyValuePairNode : MarcoTreeNode {
    weak var parent: MarcoNode? = nil
    var offset: Int = 0
    
    var children: [MarcoNode]
    
    private let keyIndex: Int
    private let valueIndex: Int

    init(children: [MarcoNode], keyIndex: Int, valueIndex: Int) {
        self.children = children
        self.keyIndex = keyIndex
        self.valueIndex = valueIndex
        
        setSelfParentForChildren()
    }
    
    var value: MarcoValueNode {
        get {
            return children[valueIndex] as! MarcoValueNode
        }
        set {
            let oldValue = value
            newValue.parent = self
            children[valueIndex] = newValue
            oldValue.parent = nil
        }
    }
    
    var key: MarcoIdentifierLikeNode {
        return children[keyIndex] as! MarcoIdentifierLikeNode
    }
    
    func clone() -> MarcoNode {
        let newChildren = children.map { $0.clone() }
        return MarcoKeyValuePairNode(children: newChildren, keyIndex: keyIndex, valueIndex: valueIndex)
    }
}
