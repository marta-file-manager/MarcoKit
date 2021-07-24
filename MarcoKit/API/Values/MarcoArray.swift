import Foundation

/** Marco array value. */
public protocol MarcoArray : MarcoValue {
    /** Element count. */
    var count: Int { get }

    /** Returns an element on an `index` position. */
    subscript(index: Int) -> MarcoValue { get set }

    /** Inserts an element on an `index` position. */
    func insert(_ value: MarcoValue, at index: Int)

    /** Removes an element on an `index` position. */
    func remove(at index: Int)
}

public extension MarcoArray {
    /** True if the array is empty. */
    var isEmpty: Bool {
        return count == 0
    }

    /** True if the array is not empty. */
    var isNotEmpty: Bool {
        return count > 0
    }

    /** Appends an element to the array. */
    func add(_ value: MarcoValue) {
        insert(value, at: count)
    }

    /** Returns all elements. The new array instance will be created. */
    var elements: [MarcoValue] {
        let count = self.count

        var result = [MarcoValue]()
        result.reserveCapacity(count)

        for i in 0..<count {
            result.append(self[i])
        }

        return result
    }

    /** Iterates over all elements. */
    func forEach(_ body: (MarcoValue) throws -> ()) rethrows {
        for i in 0..<self.count {
            try body(self[i])
        }
    }

    /** Returns `true` if `predicate` returns `true` for all elements. */
    func all(predicate: (MarcoValue) throws -> Bool) rethrows -> Bool {
        for i in 0..<self.count {
            if !(try predicate(self[i])) {
                return false
            }
        }

        return true
    }

    /** Returns `true` if `predicate` returns `false` for all elements. */
    func none(predicate: (MarcoValue) throws -> Bool) rethrows -> Bool {
        return try !any(predicate: predicate)
    }

    /** Returns `true` if `predicate` returns `true` at least for one element. */
    func any(predicate: (MarcoValue) throws -> Bool) rethrows -> Bool {
        for i in 0..<self.count {
            if try predicate(self[i]) {
                return true
            }
        }

        return false
    }

    /** Returns the first value for which `predicate` returns `true`. */
    func first(where predicate: (MarcoValue) throws -> Bool) rethrows -> MarcoValue? {
        for i in 0..<self.count {
            let item = self[i]
            if try predicate(item) {
                return self[i]
            }
        }

        return nil
    }

    /** Returns the first value for which `predicate` returns `true`. */
    func firstIndex(where predicate: (MarcoValue) throws -> Bool) rethrows -> Int? {
        for i in 0..<self.count {
            let item = self[i]
            if (try predicate(item)) {
                return i
            }
        }

        return nil
    }

    /** Removes an element with a specified `value`. */
    func remove(_ value: MarcoValue) -> Bool {
        for i in 0..<count {
            if (self[i] === value) {
                remove(at: i)
                return true
            }
        }

        return false
    }
    
    /** Returns a `Sequence` representation of the array. */
    func sequence() -> MarcoArraySequence {
        return MarcoArraySequence(self)
    }

    func accept<V, D, R>(_ visitor: V, data: D) -> R where V: MarcoVisitor, V.ReturnType == R, V.Data == D {
        return visitor.visitArray(value: self, data: data)
    }

    func equals(other: MarcoValue) -> Bool {
        guard let other = other as? MarcoArray, self.count == other.count else { return false }
        return (0..<self.count).allSatisfy { index in self[index].equals(other: other[index]) }
    }
}

public struct MarcoArraySequence : Sequence, IteratorProtocol {
    private let array: MarcoArray
    private let count: Int
    private var index = 0
    
    init(_ array: MarcoArray) {
        self.array = array
        self.count = array.count
    }
    
    public func makeIterator() -> MarcoArraySequence {
        return self
    }
    
    public mutating func next() -> MarcoValue? {
        precondition(array.count == self.count, "Concurrent array modification detected")
        guard self.count > index else { return nil }
        let result = array[index]
        index += 1
        return result
    }
}
