import Foundation

internal class ToJsonVisitor : MarcoVisitor {
    static let instance = ToJsonVisitor()
    private init() {}

    private let jsonEncoder = JSONEncoder()

    typealias ReturnType = String
    typealias Data = ()

    func visitValue(value: MarcoValue, data: ()) -> String {
        preconditionFailure()
    }

    func visitNumber(value: MarcoNumberLiteral, data: ()) -> String {
        preconditionFailure()
    }

    func visitDocument(value: MarcoDocument, data: ()) -> String {
        return value.value.accept(self)
    }

    func visitInt(value: MarcoIntLiteral, data: ()) -> String {
        return encodeValue(value.intValue)
    }

    func visitDouble(value: MarcoDoubleLiteral, data: ()) -> String {
        return encodeValue(value.doubleValue)
    }

    func visitObject(value: MarcoObject, data: ()) -> String {
        let v = value.keys.map { k in encodeValue(k) + ": " + value[k]!.accept(self) }.joined(separator: ", ")
        return "{" + v + "}"
    }

    func visitArray(value: MarcoArray, data: ()) -> String {
        return "[" + value.elements.map { $0.accept(self) }.joined(separator: ", ") + "]"
    }

    func visitNull(value: MarcoNullLiteral, data: ()) -> String {
        return "null"
    }

    func visitBool(value: MarcoBoolLiteral, data: ()) -> String {
        return (value.value) ? "true" : "false"
    }

    func visitString(value: MarcoStringLiteral, data: ()) -> String {
        return encodeValue(value.value)
    }

    private func encodeValue<T>(_ value: T) -> String where T : Encodable {
        let array = [value]
        let arrayJson = String(data: try! jsonEncoder.encode(array), encoding: .utf8)!
        assert(arrayJson.hasPrefix("[") && arrayJson.hasSuffix("]"))
        return String(arrayJson.dropFirst().dropLast())
    }
}
