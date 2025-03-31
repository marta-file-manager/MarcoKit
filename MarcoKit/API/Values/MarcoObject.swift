import Foundation

/** Marco object value. */
public protocol MarcoObject: MarcoValue {
    /** Element count. */
    var count: Int { get }

    /** All value keys. */
    var keys: [String] { get }

    /** Returns an element for a specified `key`. */
    subscript(key: String) -> MarcoValue? { get set }

    /** Returns a key identifier for a specified `key`. */
    func identifier(key: String) -> MarcoIdentifier?

    /** Removes an element with a specified `key`. */
    @discardableResult
    func remove(for key: String) -> Bool
}

public extension MarcoObject {
    /** True if the object is empty. */
    var isEmpty: Bool {
        return count == 0
    }

    /** True if the object is not empty. */
    var isNotEmpty: Bool {
        return count > 0
    }

    /** Returns all elements. The new array instance will be created. */
    var elements: [String: MarcoValue] {
        var result = [String: MarcoValue]()
        result.reserveCapacity(keys.count)

        for key in keys {
            result[key] = self[key]
        }

        return result
    }

    /** Iterates over all elements. */
    func forEach(_ body: (String, MarcoValue) throws -> ()) rethrows {
        for key in keys {
            try body(key, self[key]!)
        }
    }

    /** Returns `true` if `predicate` returns `true` for all elements. */
    func all(predicate: (String, MarcoValue) throws -> Bool) rethrows -> Bool {
        for key in keys {
            if !(try predicate(key, self[key]!)) {
                return false
            }
        }

        return true
    }

    /** Returns `true` if `predicate` returns `false` for all elements. */
    func none(predicate: (String, MarcoValue) throws -> Bool) rethrows -> Bool {
        return try !any(predicate: predicate)
    }

    /** Returns `true` if `predicate` returns `true` at least for one element. */
    func any(predicate: (String, MarcoValue) throws -> Bool) rethrows -> Bool {
        for key in keys {
            if try predicate(key, self[key]!) {
                return true
            }
        }

        return false
    }
    
    /** Returns an element with a specified key sequence. */
    subscript(keys: String...) -> MarcoValue? {
        return self[keys]
    }
    
    /** Returns an element with a specified key sequence. */
    subscript(keys: [String]) -> MarcoValue? {
        var current: MarcoValue = self
        for key in keys {
            guard let next = (current as? MarcoObject)?[key] else { return nil }
            current = next
        }
        
        return current
    }
    
    /** Returns a `Sequence` representation of the object. */
    func sequence() -> MarcoObjectSequence {
        return MarcoObjectSequence(self)
    }

    func accept<V, D, R>(_ visitor: V, data: D) -> R where V: MarcoVisitor, V.ReturnType == R, V.Data == D {
        return visitor.visitObject(value: self, data: data)
    }

    func equals(other: MarcoValue) -> Bool {
        guard let other = other as? MarcoObject else { return false }
        let selfKeys = self.keys, otherKeys = other.keys

        return selfKeys == otherKeys && selfKeys.allSatisfy { key in
            guard let selfItem = self[key], let otherItem = other[key] else { return false }
            return selfItem.equals(other: otherItem)
        }
    }
}

/** Marco object key identifier. */
public protocol MarcoIdentifier {
    /** Identifier text. */
    var value: String { get }
    
    /** Element offset in a parent. Call `MarcoDocument`.`updateOffsets()` to initialize this property. */
    var offset: Int { get }
    
    /** Element range. */
    var range: Range<Int> { get }
}

public struct MarcoObjectSequence: Sequence, IteratorProtocol {
    private let object: MarcoObject
    private let keys: [String]
    private var index = 0
    
    init(_ object: MarcoObject) {
        self.object = object
        self.keys = object.keys
    }
    
    public func makeIterator() -> MarcoObjectSequence {
        return self
    }
    
    public mutating func next() -> (String, MarcoValue)? {
        precondition(object.count == keys.count, "Concurrent object modification detected")
        guard keys.count > index else { return nil }
        let key = keys[index]
        guard let value = object[key] else { preconditionFailure("Concurrent object modification detected") }
        index += 1
        return (key, value)
    }
}
