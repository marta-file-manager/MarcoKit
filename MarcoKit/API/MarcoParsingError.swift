import Foundation

/** Marco parsing error. */
public struct MarcoParsingError: Error, Sendable {
    /** Error message. */
    public let message: String

    /** Error offset. */
    public let range: Range<String.Index>

    internal init(message: String, range: Range<String.Index>) {
        self.message = message
        self.range = range
    }
}
