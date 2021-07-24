import Foundation

/** Marco document value. */
public protocol MarcoDocument: MarcoValue {
    var text: String { get }

    /** Root value. */
    var value: MarcoValue { get set }

    /** Updates offsets for all child values recursively. */
    func updateOffsets()
}

public extension MarcoDocument {
    func accept<V, D, R>(_ visitor: V, data: D) -> R where V: MarcoVisitor, V.ReturnType == R, V.Data == D {
        return visitor.visitDocument(value: self, data: data)
    }

    var description: String {
        return value.description
    }

    func equals(other: MarcoValue) -> Bool {
        guard let other = other as? MarcoDocument else { return false }
        return self.value.equals(other: other.value)
    }
}
