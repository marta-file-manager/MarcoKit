import Foundation

/** Marco utilities. */
public class Marco {
    private init() {}

    /** Parsing options. */
    public struct Options : OptionSet {
        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        /** Parse a configuration file. */
        public static let config = Options(rawValue: 1)

        /** Throw `MarcoNonStrictParsingError` in case of non-critical parsing erorrs. */
        public static let nonStrict = Options(rawValue: 2)

        public static let showContextInErrors = Options(rawValue: 4)
    }

    /** Returns a parsed document. */
    public static func parse(_ text: String, options: Options = []) throws -> MarcoDocument {
        return try MarcoParser.parse(text: text, options: options)
    }

    /** Wraps a `value` with a `MarcoDocument` value. */
    public static func document(from value: MarcoValue) -> MarcoDocument {
        return MarcoDocumentNode(children: [value as! MarcoNode], valueIndex: 0)
    }

    /** Returns an empty Marco array value. */
    public static func emptyArray() -> MarcoArray {
        return MarcoArrayNode(children: [
            MarcoStructuralElementNode(.leftSquareBracket),
            MarcoStructuralElementNode(.rightSquareBracket)
        ], elementIndices: [])
    }

    /** Returns an empty Marco object value. */
    public static func emptyObject() -> MarcoObject {
        return MarcoObjectNode(children: [
            MarcoStructuralElementNode(.leftCurlyBracket),
            MarcoStructuralElementNode(.rightCurlyBracket)
        ], keyMappings: [:], isConfig: false)
    }

    /** Returns an empty configuration value. */
    public static func emptyConfig() -> MarcoObject {
        return MarcoObjectNode(children: [], keyMappings: [:], isConfig: true)
    }

    /** Returns an array value with the given elements. */
    public static func array(_ elements: MarcoValue...) -> MarcoArray {
        return array(elements: elements)
    }

    /** Returns an array value with the given elements. */
    public static func array(elements: [MarcoValue]) -> MarcoArray {
        var children = [MarcoNode](), elementIndices = [Int]()
        children.reserveCapacity(elements.count * 2 + 1)
        elementIndices.reserveCapacity(elements.count)

        children.append(MarcoStructuralElementNode(.leftSquareBracket))

        for element in elements {
            if (children.count > 1) {
                children.append(WS(" "))
            }

            elementIndices.append(children.count)
            children.append(element as! MarcoNode)
        }

        children.append(MarcoStructuralElementNode(.rightSquareBracket))

        return MarcoArrayNode(children: children, elementIndices: elementIndices)
    }

    /** Returns an object value with the given elements. */
    public static func object(_ elements: (String, MarcoValue)...) -> MarcoObject {
        return object(elements: elements)
    }

    /** Returns an object value with the given elements. */
    public static func object(elements: [(String, MarcoValue)]) -> MarcoObject {
        var children = [MarcoNode](), keyMappings = [String: Int]()
        children.reserveCapacity(elements.count * 2 + 1)
        keyMappings.reserveCapacity(elements.count)

        children.append(MarcoStructuralElementNode(.leftCurlyBracket))

        for (key, value) in elements {
            if (children.count > 1) {
                children.append(WS(" "))
            }

            let keyNode: MarcoNode
            if (MarcoParser.isSimpleKey(key: key)) {
                keyNode = MarcoIdentifierNode(name: key)
            } else {
                keyNode = MarcoStringLiteralNode(value: key)
            }

            let keyValuePairNode = MarcoKeyValuePairNode(
                children: [keyNode, WS(" "), value as! MarcoNode],
                keyIndex: 0, valueIndex: 2)

            keyMappings[key] = children.count
            children.append(keyValuePairNode)
        }

        children.append(MarcoStructuralElementNode(.rightCurlyBracket))

        return MarcoObjectNode(children: children, keyMappings: keyMappings, isConfig: false)
    }
}

public extension Marco {
    /**
        Returns a minified copy of the value.

        This does not change the original value.
        All insignificant whitespaces will be removed.
    */
    static func minify(_ value: MarcoValue) -> MarcoValue {
        return value.accept(MinifyingVisitor.instance)
    }

    /**
        Prettifies the value.

        This does not change the original value.
        All existing formatting will be removed.
    */
    static func prettify(_ value: MarcoValue, reorderKeys: Bool = true) -> MarcoValue {
        return value.accept(
            PrettifyingVisitor(forceNewLine: false, isRecursive: true, reorderKeys: reorderKeys),
            data: 0)
    }

    /** Returns a JSON string for the given Marco object. */
    static func toJsonString(_ value: MarcoValue) -> String {
        return value.accept(ToJsonVisitor.instance)
    }

    /** Returns a Marco object got from the parsed JSON representation. */
    static func fromJson(object json: Any) -> MarcoDocument {
        return JsonToMarcoConverter.instance.convert(json: json)
    }

    /** Returns a Marco configuration object from the parsed JSON representation. */
    static func configFromJson(object json: [String: Any]) -> MarcoDocument {
        return JsonToMarcoConverter.instance.convertConfig(json: json)
    }
}
