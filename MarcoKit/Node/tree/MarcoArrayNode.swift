import Foundation

internal class MarcoArrayNode : MarcoCollectionNode, MarcoValueNode, MarcoArray {
    weak var parent: MarcoNode? = nil
    var offset: Int = 0
    
    var children: [MarcoNode]
    var elementIndices: [Int]

    init(children: [MarcoNode], elementIndices: [Int]) {
        self.children = children
        self.elementIndices = elementIndices
        
        setSelfParentForChildren()
    }

    var hasEnclosingElements: Bool  {
        return true
    }

    var count: Int {
        return elementIndices.count
    }
    
    subscript(index: Int) -> MarcoValue {
        get {
            checkElementIndex(index)
            return children[elementIndices[index]] as! MarcoValue
        }
        set(value) {
            checkElementIndex(index)
            
            let valueNode = castToNodeCheckParent(value.unwrapDocument())
            let rawIndex = elementIndices[index]
            valueNode.applyIndent(indent: whitespaceBeforeChild(index: rawIndex).textAfterNewLine())
            valueNode.parent = self

            let previousNode = children[rawIndex]
            children[rawIndex] = valueNode
            previousNode.parent = nil
        }
    }
    
    var elements: [MarcoValue] {
        var result = [MarcoValue]()
        result.reserveCapacity(elementIndices.count)
        
        for index in elementIndices {
            result.append(children[index] as! MarcoValue)
        }
        
        return result
    }

    func insert(_ value: MarcoValue, at index: Int) {
        checkElementIndex(index, allowSizeIndex: true)
        let valueNode = castToNodeCheckParent(value.unwrapDocument())
        
        let (delta, pos) = collectionInsert(index: index, node: valueNode)

        if (delta != 0) {
            shiftElementIndices(from: index, delta: delta)
        }

        elementIndices.insert(pos, at: index)
    }
    
    func remove(at index: Int) {
        checkElementIndex(index)

        let range = collectionRemove(rawIndex: elementIndices[index])

        shiftElementIndices(from: index + 1, delta: -range.count)
        elementIndices.remove(at: index)
    }
    
    func clone() -> MarcoNode {
        let newChildren = children.map { $0.clone() }
        return MarcoArrayNode(children: newChildren, elementIndices: elementIndices)
    }
    
    private func checkElementIndex(_ index: Int, allowSizeIndex: Bool = false) {
        let indexLimit = allowSizeIndex ? elements.count + 1 : elements.count
        precondition(
            index >= 0 && index < indexLimit,
            "Index \(index) is out of bounds: [0, \(indexLimit))")
    }
    
    private func shiftElementIndices(from: Int, delta: Int) {
        var index = from
        while (index < elementIndices.count) {
            elementIndices[index] += delta
            index += 1
        }
    }
}