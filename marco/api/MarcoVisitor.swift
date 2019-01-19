import Foundation

/** Marco value visitor. */
public protocol MarcoVisitor {
    /** Return value type. */
    associatedtype ReturnType

    /** Additional data type. */
    associatedtype Data

    /** Value handler. */
    func visitValue(value: MarcoValue, data: Data) -> ReturnType

    /** Document value handler. */
    func visitDocument(value: MarcoDocument, data: Data) -> ReturnType

    /** Object value handler. */
    func visitObject(value: MarcoObject, data: Data) -> ReturnType

    /** Array value handler. */
    func visitArray(value: MarcoArray, data: Data) -> ReturnType

    /** Null value handler. */
    func visitNull(value: MarcoNullLiteral, data: Data) -> ReturnType

    /** Boolean value handler. */
    func visitBool(value: MarcoBoolLiteral, data: Data) -> ReturnType

    /** String value handler. */
    func visitString(value: MarcoStringLiteral, data: Data) -> ReturnType

    /** Number value handler. */
    func visitNumber(value: MarcoNumberLiteral, data: Data) -> ReturnType

    /** Integer value handler. */
    func visitInt(value: MarcoIntLiteral, data: Data) -> ReturnType

    /** Double value handler. */
    func visitDouble(value: MarcoDoubleLiteral, data: Data) -> ReturnType
}

public extension MarcoVisitor {
    public func visitInt(value: MarcoIntLiteral, data: Data) -> ReturnType {
        return visitNumber(value: value, data: data)
    }

    public func visitDouble(value: MarcoDoubleLiteral, data: Data) -> ReturnType {
        return visitNumber(value: value, data: data)
    }

    public func visitDocument(value: MarcoDocument, data: Data) -> ReturnType {
        return visitValue(value: value, data: data)
    }

    public func visitObject(value: MarcoObject, data: Data) -> ReturnType {
        return visitValue(value: value, data: data)
    }

    public func visitArray(value: MarcoArray, data: Data) -> ReturnType {
        return visitValue(value: value, data: data)
    }

    public func visitNull(value: MarcoNullLiteral, data: Data) -> ReturnType {
        return visitValue(value: value, data: data)
    }

    public func visitBool(value: MarcoBoolLiteral, data: Data) -> ReturnType {
        return visitValue(value: value, data: data)
    }

    public func visitString(value: MarcoStringLiteral, data: Data) -> ReturnType {
        return visitValue(value: value, data: data)
    }

    public func visitNumber(value: MarcoNumberLiteral, data: Data) -> ReturnType {
        return visitValue(value: value, data: data)
    }
}
