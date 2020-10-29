import Foundation

/** Marco boolean value. */
public protocol MarcoBoolLiteral : MarcoValue {
    /** `Bool` value. */
    var value: Bool { get }
}

public extension MarcoBoolLiteral {
    func accept<V, D, R>(_ visitor: V, data: D) -> R where V: MarcoVisitor, V.ReturnType == R, V.Data == D {
        return visitor.visitBool(value: self, data: data)
    }
}
