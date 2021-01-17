import Foundation

internal protocol MarcoNode : class {
    var offset: Int { get set }
    
    var parent: MarcoNode? { get set }
    var text: String { get }
    
    func clone() -> MarcoNode
}

internal protocol MarcoValueNode: MarcoNode, MarcoValue {}

internal extension MarcoNode {
    var range: Range<Int> {
        return offset..<(offset + text.count)
    }
}

internal protocol MarcoTreeNode : MarcoNode {
    var children: [MarcoNode] { get set }
    
    func updateOffsets()
}

internal protocol MarcoCollectionNode : MarcoTreeNode, MarcoValueNode {
    var hasEnclosingElements: Bool { get }
}

internal protocol MarcoIdentifierLikeNode : MarcoNode, MarcoIdentifier {
    var value: String { get }
}

internal extension MarcoTreeNode {
    var text: String {
        var result = ""
        
        for child in children {
            result.append(child.text)
        }
        
        return result
    }
    
    func setSelfParentForChildren() {
        for child in children {
            precondition(child.parent == nil)
            child.parent = self
        }
    }
    
    func updateOffsets() {
        var offset = self.offset
        for child in children {
            child.offset = offset
            if let treeNode = child as? MarcoTreeNode {
                treeNode.updateOffsets()
            }
            offset += child.text.count
        }
    }
}
