import Foundation

/** Marco double value. */
public protocol MarcoDoubleLiteral : MarcoNumberLiteral {}

public extension MarcoDoubleLiteral {
    public var intValue: Int {
        return Int(doubleValue)
    }

    public func accept<V, D, R>(_ visitor: V, data: D) -> R where V: MarcoVisitor, V.ReturnType == R, V.Data == D {
        return visitor.visitDouble(value: self, data: data)
    }
}
