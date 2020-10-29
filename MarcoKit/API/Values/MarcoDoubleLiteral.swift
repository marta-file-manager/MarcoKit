import Foundation

/** Marco double value. */
public protocol MarcoDoubleLiteral : MarcoNumberLiteral {}

public extension MarcoDoubleLiteral {
    var intValue: Int {
        return Int(doubleValue)
    }

    func accept<V, D, R>(_ visitor: V, data: D) -> R where V: MarcoVisitor, V.ReturnType == R, V.Data == D {
        return visitor.visitDouble(value: self, data: data)
    }
}
