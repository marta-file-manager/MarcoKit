import Cocoa

public extension MarcoValue {
    /** Safely casts this value to an object value. */
    var asObject: MarcoObject? {
        guard let object = self as? MarcoObject else { return nil }
        return object
    }

    /** Safely casts this value to an array value. */
    var asArray: MarcoArray? {
        guard let array = self as? MarcoArray else { return nil }
        return array
    }

    /** Safely casts this value to a string value. */
    var asStringLiteral: MarcoStringLiteral? {
        guard let literal = self as? MarcoStringLiteral else { return nil }
        return literal
    }

    /** Safely casts this value to an string value, and returns the backing `String` if the cast was successful. */
    var asString: String? {
        guard let literal = self as? MarcoStringLiteral else { return nil }
        return literal.value
    }

    /** Safely casts this value to an string value, and returns the backing `String` if the cast was successful.
        Returns an empty String otherwise.
     */
    var asStringOrEmpty: String {
        return asString ?? ""
    }

    /** Safely casts this value to a number value. */
    var asNumberLiteral: MarcoNumberLiteral? {
        guard let literal = self as? MarcoNumberLiteral else { return nil }
        return literal
    }

    /** Safely casts this value to a integer value. */
    var asIntLiteral: MarcoIntLiteral? {
        guard let literal = self as? MarcoIntLiteral else { return nil }
        return literal
    }

    /** Safely casts this value to a double value. */
    var asDoubleLiteral: MarcoDoubleLiteral? {
        guard let literal = self as? MarcoDoubleLiteral else { return nil }
        return literal
    }

    /** Safely casts this value to an integer value, and returns the backing `Int` if the cast was successful. */
    var asInt: Int? {
        guard let literal = self as? MarcoIntLiteral else { return nil }
        return literal.intValue
    }

    /** Safely casts this value to an integer value, and returns the backing `Int` if the cast was successful.
        Returns `0` otherwise.
     */
    var asIntOrZero: Int {
        return asInt ?? 0
    }

    /** Safely casts this value to a double value, and returns the backing `Double` if the cast was successful. */
    var asDouble: Double? {
        guard let literal = self as? MarcoDoubleLiteral else { return nil }
        return literal.doubleValue
    }

    /** Safely casts this value to a double value, and returns the backing `Double` if the cast was successful.
        Returns `0.0` otherwise.
     */
    var asDoubleOrZero: Double {
        return asDouble ?? 0
    }

    /** Safely casts this value to a boolean value. */
    var asBoolLiteral: MarcoBoolLiteral? {
        guard let literal = self as? MarcoBoolLiteral else { return nil }
        return literal
    }

    /** Safely casts this value to a boolean value, and returns the backing `Bool` if the cast was successful. */
    var asBool: Bool? {
        guard let literal = self as? MarcoBoolLiteral else { return nil }
        return literal.value
    }

    /** Safely casts this value to a boolean value, and returns the backing `Bool` if the cast was successful.
        Returns `false` otherwise.
     */
    var asBoolOrFalse: Bool {
        return asBool ?? false
    }

    /** Safely casts this value to a boolean value, and returns the backing `Bool` if the cast was successful.
        Returns `true` otherwise.
     */
    var asBoolOrTrue: Bool {
        return asBool ?? true
    }

    /** Safely casts this value to a null value. */
    var asNullLiteral: MarcoNullLiteral? {
        guard let literal = self as? MarcoNullLiteral else { return nil }
        return literal
    }

    /** True if this value is a null value. */
    var isNull: Bool {
        return self is MarcoNullLiteral
    }
    
    /** Safely casts this value to a color integer value, and converts it into an `NSColor`. */
    func asColor(useAlpha: Bool = false) -> NSColor? {
        guard let intValue = asInt else { return nil }
        return getColor(intValue, useAlpha: useAlpha)
    }
    
    /** Safely casts this value to a color integer value, and converts it into an `NSColor`. */
    var asColor: NSColor? {
        if let colorNode = self as? MarcoColorLiteralNode {
            return getColor(colorNode.intValue, useAlpha: colorNode.useAlpha)
        }
        
        guard let intValue = asInt else { return nil }
        let useAlpha = (intValue & 0xff000000) != 0
        return getColor(intValue, useAlpha: useAlpha)
    }
    
    private func getColor(_ intValue: Int, useAlpha: Bool = false) -> NSColor {
        let alpha = useAlpha ? CGFloat((intValue & 0xff000000) >> 24) / 255.0 : 1.0
        let red = CGFloat((intValue & 0xff0000) >> 16) / 255.0
        let green = CGFloat((intValue & 0xff00) >> 8) / 255.0
        let blue = CGFloat((intValue & 0xff) >> 0) / 255.0
        let color = NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
        return color
    }
}
