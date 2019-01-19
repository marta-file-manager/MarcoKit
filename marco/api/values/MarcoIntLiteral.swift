import Foundation

/** Marco integer value. */
public protocol MarcoIntLiteral : MarcoNumberLiteral {
    var isColor: Bool { get }
}

public extension MarcoIntLiteral {
    public var doubleValue: Double {
        return Double(intValue)
    }

    public func accept<V, D, R>(_ visitor: V, data: D) -> R where V: MarcoVisitor, V.ReturnType == R, V.Data == D {
        return visitor.visitInt(value: self, data: data)
    }
}
