import Foundation

internal class MarcoDocumentNode : MarcoTreeNode, MarcoValueNode, MarcoDocument {
    weak var parent: MarcoNode? = nil
    var offset: Int = 0

    var children: [MarcoNode]

    private let valueIndex: Int

    init(children: [MarcoNode], valueIndex: Int) {
        self.children = children
        self.valueIndex = valueIndex

        setSelfParentForChildren()
    }

    var value: MarcoValue {
        get {
            return children[valueIndex] as! MarcoValue
        }
        set {
            let oldValueNode = value as! MarcoValueNode
            let newValueNode = newValue as! MarcoValueNode

            newValueNode.parent = self
            children[valueIndex] = newValueNode
            oldValueNode.parent = nil
        }
    }

    func clone() -> MarcoNode {
        return MarcoDocumentNode(children: children, valueIndex: valueIndex)
    }
}
