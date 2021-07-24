import Foundation

/** Marco integer value. */
public protocol MarcoIntLiteral : MarcoNumberLiteral {
    /** True if this literal is a color literal. */
    var isColor: Bool { get }
}

public extension MarcoIntLiteral {
    var doubleValue: Double {
        return Double(intValue)
    }

    func accept<V, D, R>(_ visitor: V, data: D) -> R where V: MarcoVisitor, V.ReturnType == R, V.Data == D {
        return visitor.visitInt(value: self, data: data)
    }

    func equals(other: MarcoValue) -> Bool {
        return self.intValue == (other as? MarcoIntLiteral)?.intValue
    }
}
