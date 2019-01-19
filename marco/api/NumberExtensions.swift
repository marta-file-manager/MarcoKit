import Foundation

public extension MarcoNumberLiteral {
    public var int32Value: Int32 {
        return Int32(intValue)
    }
    
    public var uint32value: UInt32 {
        return UInt32(intValue)
    }
    
    public var int64Value: Int64 {
        return Int64(intValue)
    }
    
    public var uint64Value: UInt64 {
        return UInt64(intValue)
    }
    
    public var floatValue: Float {
        return Float(doubleValue)
    }
    
    public var cgFloatValue: CGFloat {
        return CGFloat(doubleValue)
    }
}
