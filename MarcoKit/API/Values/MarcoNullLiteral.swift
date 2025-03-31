import Foundation

/** Marco null value. */
public protocol MarcoNullLiteral: MarcoValue {}

public extension MarcoNullLiteral {
    func accept<V, D, R>(_ visitor: V, data: D) -> R where V: MarcoVisitor, V.ReturnType == R, V.Data == D {
        return visitor.visitNull(value: self, data: data)
    }

    func equals(other: MarcoValue) -> Bool {
        return other is MarcoNullLiteral
    }
}
