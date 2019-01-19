import Foundation

internal class JsonToMarcoConverter {
    static let instance = JsonToMarcoConverter()
    private init() {}

    func convert(json: Any?) -> MarcoDocument {
        let node = convertValue(json: json)
        return MarcoDocumentNode(children: [node], valueIndex: 0)
    }

    func convertConfig(json: [String: Any]) -> MarcoDocument {
        let node = convertObject(json, isConfig: true)
        return MarcoDocumentNode(children: [node], valueIndex: 0)
    }

    private func convertValue(json: Any?) -> MarcoValueNode {
        if (json is NSNull) {
            return MarcoNullLiteralNode()
        } else if let json = json as? String {
            return MarcoStringLiteralNode(value: json)
        } else if let json = json as? NSNumber {
            let typeId = CFGetTypeID(json as CFTypeRef)
            if (typeId == CFBooleanGetTypeID()) {
                return MarcoBoolLiteralNode(value: json.boolValue)
            } else if (typeId == CFNumberGetTypeID()) {
                switch (CFNumberGetType(json as CFNumber)) {
                    case .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type, .cfIndexType,
                         .shortType, .intType, .longType, .longLongType, .nsIntegerType:
                        return MarcoIntLiteralNode(value: json.intValue)
                    case .float32Type, .float64Type, .floatType, .doubleType, .cgFloatType:
                        return MarcoDoubleLiteralNode(value: json.doubleValue)
                    case .charType:
                        return MarcoStringLiteralNode(value: json.stringValue)
                }
            } else {
                preconditionFailure("Unknown element type: \(json)")
            }
        } else if let json = json as? [Any] {
            return convertArray(json)
        } else if let json = json as? [String: Any] {
            return convertObject(json, isConfig: false)
        } else {
            preconditionFailure("Unknown element type: \(String(describing: json))")
        }
    }

    private func convertObject(_ dict: [String: Any], isConfig: Bool) -> MarcoObjectNode {
        var nodes = [MarcoNode]()
        var keyMappings = [String: Int]()

        nodes.reserveCapacity(dict.count * 2 - 1 + (isConfig ? 0 : 2))
        keyMappings.reserveCapacity(dict.count)

        if (!isConfig) {
            nodes.append(MarcoStructuralElementNode(.leftCurlyBracket))
        }

        let keys = dict.keys.sorted()
        var isFirst = true

        for key in keys {
            let value = dict[key]
            let keyNode: MarcoNode = MarcoParser.isSimpleKey(key: key)
                ? MarcoIdentifierNode(name: key) : MarcoStringLiteralNode(value: key)
            let valueNode = convertValue(json: value)

            if (isFirst) {
                isFirst = false
            } else {
                nodes.append(WS(" "))
            }

            keyMappings[key] = nodes.count
            nodes.append(MarcoKeyValuePairNode(children: [keyNode, WS(" "), valueNode], keyIndex: 0, valueIndex: 2))
        }

        if (!isConfig) {
            nodes.append(MarcoStructuralElementNode(.rightCurlyBracket))
        }

        return MarcoObjectNode(children: nodes, keyMappings: keyMappings, isConfig: isConfig)
    }

    private func convertArray(_ array: [Any]) -> MarcoArrayNode {
        var nodes = [MarcoNode]()
        var elementIndices = [Int]()

        nodes.reserveCapacity(array.count * 2 + 1)
        elementIndices.reserveCapacity(array.count)
        
        nodes.append(MarcoStructuralElementNode(.leftSquareBracket))

        for value in array {
            if (!nodes.isEmpty) {
                nodes.append(WS(" "))
            }

            elementIndices.append(nodes.count)
            nodes.append(convertValue(json: value))
        }
        
        nodes.append(MarcoStructuralElementNode(.rightSquareBracket))

        return MarcoArrayNode(children: nodes, elementIndices: elementIndices)
    }
}
