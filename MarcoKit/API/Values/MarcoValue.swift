import Foundation

/** Marco value. */
public protocol MarcoValue : AnyObject, CustomStringConvertible {
    /** Element offset in a parent. Call `MarcoDocument`.`updateOffsets()` to initialize this property. */
    var offset: Int { get }

    /** Element range. */
    var range: Range<Int> { get }

    /** Value text. */
    var text: String { get }

    /** Pass this element to the given `visitor`. */
    func accept<V, D, R>(_ visitor: V, data: D) -> R where V : MarcoVisitor, V.ReturnType == R, V.Data == D

    /** Compares Marco nodes. Returns `true` if the content of both nodes is recursively equivalent. */
    func equals(other: MarcoValue) -> Bool
}

public extension MarcoValue {
    var description: String {
        return text
    }

    func accept<V, R>(_ visitor: V) -> R where V : MarcoVisitor, V.ReturnType == R, V.Data == () {
        return accept(visitor, data: ())
    }
    
    /** Returns an underlying Marco document, or `nil` if the current value is not currently attached to a document. */
    var document: MarcoDocument? {
        if let doc = self as? MarcoDocument {
            return doc
        }
        
        guard var parent = (self as! MarcoNode).parent else { return nil }
        while (true) {
            if let doc = parent as? MarcoDocument {
                return doc
            }
            
            guard let newParent = parent.parent else { return nil }
            parent = newParent
        }
    }
}
