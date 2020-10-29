import Foundation

/** Marco number value. */
public protocol MarcoNumberLiteral : MarcoValue {
    /** Int value. Check if this value is `MarcoIntLiteral` to avoid conversion. */
    var intValue: Int { get }

    /** Double value. Check if this value is `MarcoDoubleLiteral` to avoid conversion. */
    var doubleValue: Double { get }
}

public extension MarcoNumberLiteral {
    func accept<V, D, R>(_ visitor: V, data: D) -> R where V: MarcoVisitor, V.ReturnType == R, V.Data == D {
        return visitor.visitNumber(value: self, data: data)
    }
}
