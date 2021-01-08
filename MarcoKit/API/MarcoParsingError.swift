import Foundation

/** Marco parsing error. */
public class MarcoParsingError : Error {
    /** Error message. */
    public let message: String

    /** Error offset. */
    public let range: Range<String.Index>

    internal init(message: String, range: Range<String.Index>) {
        self.message = message
        self.range = range
    }
}

/** Marco non-strict parsing error. This is only thrown when the `Marco.Options.nonStrict` flag is set. */
public class MarcoNonStrictParsingError : Error {
    /** Parsing errors. */
    public let errors: [MarcoParsingError]

    /** Parsed document. */
    public let document: MarcoDocument
    
    public var localizedDescription: String {
        return errors.lazy.map { $0.localizedDescription }.joined()
    }

    internal init(errors: [MarcoParsingError], document: MarcoDocument) {
        self.errors = errors
        self.document = document
    }
}
