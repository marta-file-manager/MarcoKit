import Foundation

class MutatingPrettifyingVisitor : PrettifyingVisitor {
    override func visitDocument(value: MarcoDocument, data: Int) -> MarcoValueNode {
        let result = super.visitDocument(value: value, data: data) as! MarcoDocumentNode
        let node = value as! MarcoDocumentNode
        replaceChildren(container: node, children: result.children)
        node.valueIndex = result.valueIndex
        return node
    }

    override func visitObject(value: MarcoObject, data: Int) -> MarcoValueNode {
        let result = super.visitObject(value: value, data: data) as! MarcoObjectNode
        let node = value as! MarcoObjectNode
        replaceChildren(container: node, children: result.children)
        node.keyMappings = result.keyMappings
        return node
    }

    override func visitArray(value: MarcoArray, data: Int) -> MarcoValueNode {
        let result = super.visitArray(value: value, data: data) as! MarcoArrayNode
        let node = value as! MarcoArrayNode
        replaceChildren(container: node, children: result.children)
        node.elementIndices = result.elementIndices
        return node
    }

    private func replaceChildren(container: MarcoTreeNode, children: [MarcoNode]) {
        let oldChildren = container.children
        children.forEach { $0.parent = container }
        container.children = children
        oldChildren.forEach { $0.parent = nil }
    }
}