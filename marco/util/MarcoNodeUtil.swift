import Foundation

internal let SINGLE_INDENT = "    "

internal func castToNodeCheckParent(_ value: MarcoValue) -> MarcoValueNode {
    guard let node = value as? MarcoValueNode
        else { preconditionFailure("Value \(value.description) must be a node") }
    checkParent(node)
    return node
}

internal func checkParent(_ node: MarcoNode) {
    guard node.parent == nil
        else { preconditionFailure("Node \(node.text) already has a parent: \(node.parent.debugDescription)") }
}

internal extension MarcoValue {
    func unwrapDocument() -> MarcoValue {
        if let document = self as? MarcoDocument {
            return document.value
        } else {
            return self
        }
    }
}

internal extension MarcoNode {
    func withOffset(_ offset: Int) -> MarcoNode {
        self.offset = offset
        return self
    }
    
    var isIgnoring: Bool {
        if let structural = self as? MarcoStructuralElementNode, structural.kind == .ignoring {
            return true
        }
        
        return false
    }
    
    func indentInParent() -> String {
        guard let parent = self.parent as? MarcoTreeNode else { return "" }
        if (parent is MarcoKeyValuePairNode) {
            return parent.indentInParent()
        }

        guard var index = indexInParent() else { return "" }
        index -= 1

        while (index >= 0) {
            defer { index -= 1 }
            let node = parent.children[index]
            
            if node.isIgnoring {
                continue
            } else if let whitespace = node as? MarcoWhitespaceNode {
                return whitespace.text.textAfterNewLine()
            } else {
                break
            }
        }
        
        return ""
    }
    
    func indexInParent() -> Int? {
        guard let parent = self.parent as? MarcoTreeNode else { return nil }
        
        for (index, node) in parent.children.enumerated() {
            if (node === self) {
                return index
            }
        }
        
        return nil
    }
    
    func applyIndent(indent: String) {
        guard let treeNode = self as? MarcoTreeNode else { return }
        treeNode.applyIndent(indent: indent)
    }
}

internal extension MarcoTreeNode {
    func applyIndent(indent: String) {
        guard !indent.isEmpty else { return }
        
        for index in 0..<children.count {
            let node = children[index]
            if let node = node as? MarcoWhitespaceNode {
                guard node.containsNewLine else { continue }

                let newText = node.text.replacingOccurrences(of: "\n", with: "\n" + indent)
                let newNode = WSnl(newText)
                newNode.parent = self
                children[index] = newNode

                node.parent = nil
            } else if let node = node as? MarcoTreeNode {
                node.applyIndent(indent: indent)
            }
        }
    }
    
    func whitespaceBeforeChild(index: Int) -> String {
        var currentIndex = index - 1
        while (currentIndex > 0) {
            defer { currentIndex -= 1}
            
            let node = children[currentIndex]
            if (node.isIgnoring) {
                continue
            } else if let whitespace = node as? MarcoWhitespaceNode {
                return whitespace.text
            }
        }
        
        return ""
    }
    
    func whitespaceAfterChild(index: Int) -> String {
        let whitespaceIndex = index + 1
        guard whitespaceIndex < children.count else { return "" }
        guard let node = children[whitespaceIndex] as? MarcoWhitespaceNode else { return "" }
        return node.text
    }
}

internal extension String {
    func textAfterNewLine() -> String {
        guard let index = lastIndex(of: "\n") else { return self }
        let nextIndex = self.index(after: index)
        return String(self[nextIndex...])
    }
}

internal func WS(_ text: String) -> MarcoWhitespaceNode {
    return MarcoWhitespaceNode(text: text, containsNewLine: false)
}

internal func WSnl(_ text: String) -> MarcoWhitespaceNode {
    return MarcoWhitespaceNode(text: text, containsNewLine: true)
}
