import Foundation

internal class PrettifyingVisitor : MarcoVisitor {
    private let indent: String
    private let forceNewLine: Bool

    init(indent: String = "    ", forceNewLine: Bool) {
        self.indent = indent
        self.forceNewLine = forceNewLine
    }

    typealias ReturnType = MarcoValueNode
    typealias Data = Int

    func visitValue(value: MarcoValue, data: Int) -> MarcoValueNode {
        return (value as! MarcoNode).clone() as! MarcoValueNode
    }

    func visitDocument(value: MarcoDocument, data: Int) -> MarcoValueNode {
        let newChild = value.value.accept(self, data: data)
        return MarcoDocumentNode(children: [newChild], valueIndex: 0)
    }

    func visitObject(value: MarcoObject, data: Int) -> MarcoValueNode {
        let valueNode = (value as! MarcoObjectNode)

        guard value.count > 0 else {
            let children: [MarcoNode]
            if (valueNode.hasEnclosingElements) {
                children = [
                    MarcoStructuralElementNode(.leftCurlyBracket),
                    MarcoStructuralElementNode(.rightCurlyBracket)
                ]
            } else {
                children = []
            }

            return MarcoObjectNode(children: children, keyMappings: [:], isConfig: !valueNode.hasEnclosingElements)
        }

        var nodes = [MarcoNode]()
        var keyMappings = [String: Int]()

        nodes.reserveCapacity(value.count * 2 + 1)
        keyMappings.reserveCapacity(value.count)

        let currentIndent = String(repeating: indent, count: data)
        let childIndent = valueNode.hasEnclosingElements ? currentIndent + indent : currentIndent

        if (valueNode.hasEnclosingElements) {
            nodes.append(MarcoStructuralElementNode(.leftCurlyBracket))
            nodes.append(WSnl("\n" + childIndent))
        }

        let sortedKeys = sortObjectKeys(keys: value.keys) { value[$0]!.isSimple }

        for key in sortedKeys {
            let dataForKey = valueNode.hasEnclosingElements ? (data + 1) : data
            let valueNodeForKey = value[key]!.accept(self, data: dataForKey)

            if (!keyMappings.isEmpty) {
                if (!valueNodeForKey.isSimple) {
                    nodes.append(WSnl("\n\n" + childIndent))
                } else {
                    nodes.append(WSnl("\n" + childIndent))
                }
            }

            let keyNode = getKeyNode(key: key)
            keyMappings[key] = nodes.count

            let keyValuePairNode = MarcoKeyValuePairNode(
                children: [keyNode, WS(" "), valueNodeForKey],
                keyIndex: 0, valueIndex: 2)

            nodes.append(keyValuePairNode)
        }

        if (valueNode.hasEnclosingElements) {
            nodes.append(WSnl("\n" + currentIndent))
            nodes.append(MarcoStructuralElementNode(.rightCurlyBracket))
        }

        return MarcoObjectNode(children: nodes, keyMappings: keyMappings, isConfig: !valueNode.hasEnclosingElements)
    }

    private func sortObjectKeys(keys: [String], isSimple: (String) -> Bool) -> [String] {
        return keys.sorted { f, s in
            let fIsSimple = isSimple(f)
            let sIsSimple = isSimple(s)

            if (fIsSimple && !sIsSimple) {
                return true
            } else if (!fIsSimple && sIsSimple) {
                return false
            } else {
                return f < s
            }
        }
    }

    private func getKeyNode(key: String) -> MarcoNode {
        if (MarcoParser.isSimpleKey(key: key)) {
            return MarcoIdentifierNode(name: key)
        } else {
            return MarcoStringLiteralNode(value: key)
        }
    }

    func visitArray(value: MarcoArray, data: Int) -> MarcoValueNode {
        guard value.count > 0 else {
            return MarcoArrayNode(children: [
                MarcoStructuralElementNode(.leftSquareBracket),
                MarcoStructuralElementNode(.rightSquareBracket)
            ], elementIndices: [])
        }

        var nodes = [MarcoNode]()
        var elementIndices = [Int]()

        nodes.reserveCapacity(value.count * 2 + 1)
        elementIndices.reserveCapacity(value.count)

        nodes.append(MarcoStructuralElementNode(.leftSquareBracket))

        if (!forceNewLine && value.count < 3 && value.all { $0.isPrimitive }) {
            nodes.append(WS(" "))

            for index in 0..<value.count {
                elementIndices.append(nodes.count)
                nodes.append(value[index].accept(self, data: data + 1))
                nodes.append(WS(" "))
            }
        } else {
            let currentIndent = String(repeating: indent, count: data)

            for index in 0..<value.count {
                nodes.append(WSnl("\n" + currentIndent + indent))
                elementIndices.append(nodes.count)
                nodes.append(value[index].accept(self, data: data + 1))
            }

            nodes.append(WSnl("\n" + currentIndent))
        }

        nodes.append(MarcoStructuralElementNode(.rightSquareBracket))

        return MarcoArrayNode(children: nodes, elementIndices: elementIndices)
    }
}

fileprivate extension MarcoValue {
    var isPrimitive: Bool {
        return !(self is MarcoArray || self is MarcoObject)
    }

    var isSimple: Bool {
        if let array = self as? MarcoArray {
            return array.count < 3 && array.all { $0.isPrimitive }
        } else if let object = self as? MarcoObject {
            return object.isEmpty
        } else {
            return true
        }
    }
}