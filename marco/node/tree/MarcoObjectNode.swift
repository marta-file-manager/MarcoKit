import Foundation

internal class MarcoObjectNode : MarcoCollectionNode, MarcoValueNode, MarcoObject {
    let hasEnclosingElements: Bool

    weak var parent: MarcoNode? = nil
    var offset: Int = 0
    
    var children: [MarcoNode]
    private var keyMappings: [String: Int]
    
    init(children: [MarcoNode], keyMappings: [String: Int], isConfig: Bool) {
        self.hasEnclosingElements = !isConfig
        self.children = children
        self.keyMappings = keyMappings
        
        setSelfParentForChildren()
    }
    
    var count: Int {
        return keyMappings.count
    }
    
    var keys: [String] {
        return keyMappings.sorted { (f, s) in f.value < s.value }.map { $0.key }
    }

    subscript(key: String) -> MarcoValue? {
        get {
            guard let index = keyMappings[key] else { return nil }
            return (children[index] as! MarcoKeyValuePairNode).value
        }
        set {
            guard let value = newValue?.unwrapDocument() else {
                _ = remove(for: key)
                return
            }
            
            guard let rawIndex = keyMappings[key] else {
                insert(key: key, value: value)
                return
            }
            
            let valueNode = castToNodeCheckParent(value)
            valueNode.applyIndent(indent: whitespaceBeforeChild(index: rawIndex).textAfterNewLine())
            (children[rawIndex] as! MarcoKeyValuePairNode).value = valueNode
        }
    }
    
    func identifier(key: String) -> MarcoIdentifier? {
        guard let index = keyMappings[key] else { return nil }
        return (children[index] as! MarcoKeyValuePairNode).key
    }
    
    func clone() -> MarcoNode {
        let newChildren = children.map { $0.clone() }
        return MarcoObjectNode(children: newChildren, keyMappings: keyMappings, isConfig: !hasEnclosingElements)
    }

    @discardableResult
    func remove(for key: String) -> Bool {
        guard let rawIndex = keyMappings[key] else { return false }

        let delta = collectionRemove(rawIndex: rawIndex).count
        
        var newKeyMappings = self.keyMappings
        newKeyMappings.removeValue(forKey: key)
        
        for (key, value) in newKeyMappings {
            if (value > rawIndex) {
                newKeyMappings[key] = value - delta
            }
        }
        
        self.keyMappings = newKeyMappings
        
        return true
    }
    
    private func insert(key: String, value: MarcoValue) {
        let index = keyMappings.count

        let keyNode: MarcoNode = MarcoParser.isSimpleKey(key: key)
            ? MarcoIdentifierNode(name: key) : MarcoStringLiteralNode(value: key)

        let valueNode = castToNodeCheckParent(value.unwrapDocument())

        let keyValuePairNode = MarcoKeyValuePairNode(
            children: [keyNode, WS(" "), valueNode],
            keyIndex: 0, valueIndex: 2)

        let (delta, pos) = collectionInsert(index: index, node: keyValuePairNode)

        var newKeyMappings = self.keyMappings
        if (delta != 0) {
            for (key, value) in newKeyMappings {
                if (value >= pos) {
                    newKeyMappings[key] = value + delta
                }
            }
        }

        newKeyMappings[key] = pos
        self.keyMappings = newKeyMappings
    }
    
    private func isFirstPair(index: Int) -> Bool {
        var current = index - 1
        while (current > 0) {
            if (children[current] is MarcoKeyValuePairNode) {
                return false
            }
            current -= 1
        }
        
        return true
    }
}
