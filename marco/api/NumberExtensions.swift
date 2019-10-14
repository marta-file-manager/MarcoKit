import Foundation

public extension MarcoNumberLiteral {
    var int32Value: Int32 {
        return Int32(intValue)
    }
    
    var uint32value: UInt32 {
        return UInt32(intValue)
    }
    
    var int64Value: Int64 {
        return Int64(intValue)
    }
    
    var uint64Value: UInt64 {
        return UInt64(intValue)
    }
    
    var floatValue: Float {
        return Float(doubleValue)
    }
    
    var cgFloatValue: CGFloat {
        return CGFloat(doubleValue)
    }
}
