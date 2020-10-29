import Foundation

internal class MinifyingVisitor : MarcoVisitor {
    public static let instance = MinifyingVisitor()
    private init() {}

    typealias ReturnType = MarcoValueNode
    typealias Data = ()
    
    func visitValue(value: MarcoValue, data: ()) -> MarcoValueNode {
        return (value as! MarcoNode).clone() as! MarcoValueNode
    }

    func visitDocument(value: MarcoDocument, data: ()) -> MarcoValueNode {
        let newChild = value.value.accept(self)
        return MarcoDocumentNode(children: [newChild], valueIndex: 0)
    }

    func visitArray(value: MarcoArray, data: ()) -> MarcoValueNode {
        var children = [MarcoNode](), elementIndices = [Int](), isIgnored = false
        children.reserveCapacity(value.count * 2 + 1)
        elementIndices.reserveCapacity(value.count)
        
        for node in (value as! MarcoArrayNode).children {
            guard !(node is MarcoWhitespaceNode) else { continue }
            
            if let valueNode = node as? MarcoValueNode {
                if (!elementIndices.isEmpty) {
                    children.append(WS(" "))
                }

                if (node is MarcoValue && !isIgnored) {
                    elementIndices.append(children.count)
                }

                children.append(valueNode.accept(self))
            } else {
                children.append(node.clone())
            }

            isIgnored = node.isIgnoring
        }
        
        return MarcoArrayNode(children: children, elementIndices: elementIndices)
    }
    
    func visitObject(value: MarcoObject, data: ()) -> MarcoValueNode {
        var children = [MarcoNode](), keyMappings = [String: Int]()
        var index = 0

        let valueNode = (value as! MarcoObjectNode)
        let oldChildren = valueNode.children

        if (valueNode.hasEnclosingElements) {
            children.append(MarcoStructuralElementNode(.leftCurlyBracket))
        }

        while (index < oldChildren.count) {
            defer { index += 1 }

            let node = oldChildren[index]
            guard let keyValuePair = node as? MarcoKeyValuePairNode else { continue }

            if (!keyMappings.isEmpty) {
                children.append(WS(" "))
            }

            let key = keyValuePair.key
            let newKey: MarcoNode

            if let key = key as? MarcoIdentifierNode {
                newKey = key.clone()
            } else {
                newKey = (key as! MarcoValue).accept(self)
            }

            keyMappings[key.value] = children.count

            let newKeyValuePair = MarcoKeyValuePairNode(children: [
                newKey, WS(" "), keyValuePair.value.accept(self)
            ], keyIndex: 0, valueIndex: 2)

            children.append(newKeyValuePair)
        }

        if (valueNode.hasEnclosingElements) {
            children.append(MarcoStructuralElementNode(.rightCurlyBracket))
        }

        return MarcoObjectNode(children: children, keyMappings: keyMappings, isConfig: !valueNode.hasEnclosingElements)
    }
}
