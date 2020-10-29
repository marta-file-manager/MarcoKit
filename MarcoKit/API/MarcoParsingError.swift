import Foundation

/** Marco parsing error. */
public class MarcoParsingError : Error {
    /** Error kind. */
    public let kind: ErrorKind

    /** Error offset. */
    public let offset: Int

    /** Error message. */
    public let message: String

    /** Error context. */
    public let context: String

    public var localizedDescription: String {
        var desc = String(offset) + ": " + message
        if (!context.isEmpty) {
            desc += "\n\n" + context
        }
        return desc
    }

    internal init(kind: ErrorKind, offset: Int, message: String, context: String) {
        self.kind = kind
        self.offset = offset
        self.message = message
        self.context = context
    }

    public enum ErrorKind : Int {
        case unknown
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
