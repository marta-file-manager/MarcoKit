import Foundation

/** Marco string value. */
public protocol MarcoStringLiteral : MarcoValue {
    var value: String { get }
}

public extension MarcoStringLiteral {
    func accept<V, D, R>(_ visitor: V, data: D) -> R where V: MarcoVisitor, V.ReturnType == R, V.Data == D {
        return visitor.visitString(value: self, data: data)
    }
}
