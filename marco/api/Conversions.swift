import Cocoa

public extension String {
    /** Returns a Marco string value. */
    public var toMarco: MarcoStringLiteral {
        return MarcoStringLiteralNode(value: self)
    }
}

public extension Int {
    /** Returns a Marco integer value. */
    public var toMarco: MarcoIntLiteral {
        return MarcoIntLiteralNode(value: self)
    }
}

public extension Int32 {
    /** Returns a Marco integer value. */
    public var toMarco: MarcoIntLiteral {
        return MarcoIntLiteralNode(value: Int(self))
    }
}

public extension UInt32 {
    /** Returns a Marco integer value. */
    public var toMarco: MarcoIntLiteral {
        return MarcoIntLiteralNode(value: Int(self))
    }
}

public extension Int64 {
    /** Returns a Marco integer value. */
    public var toMarco: MarcoIntLiteral {
        return MarcoIntLiteralNode(value: Int(self))
    }
}

public extension UInt64 {
    /** Returns a Marco integer value. */
    public var toMarco: MarcoIntLiteral {
        return MarcoIntLiteralNode(value: Int(self))
    }
}

public extension Double {
    /** Returns a Marco double value. */
    public var toMarco: MarcoDoubleLiteral {
        return MarcoDoubleLiteralNode(value: self)
    }
}

public extension Float {
    /** Returns a Marco double value. */
    public var toMarco: MarcoDoubleLiteral {
        return MarcoDoubleLiteralNode(value: Double(self))
    }
}

public extension CGFloat {
    /** Returns a Marco double value. */
    public var toMarco: MarcoDoubleLiteral {
        return MarcoDoubleLiteralNode(value: Double(self))
    }
}

public extension NSNull {
    /** Returns a Marco null value. */
    public var toMarco: MarcoNullLiteral {
        return MarcoNullLiteralNode()
    }
}

public extension Bool {
    /** Returns a Marco boolean value. */
    public var toMarco: MarcoBoolLiteral {
        return MarcoBoolLiteralNode(value: self)
    }
}

public extension NSColor {
    /** returns a Marco color integer value. */
    public var toMarco: MarcoIntLiteral {
        return MarcoColorLiteralNode(text: hexValue)
    }
    
    private var hexValue: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // TODO support opacity
        let rgb:Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255)
        return String(format:"#%06x", rgb)
    }
}
