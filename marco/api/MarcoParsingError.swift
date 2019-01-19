import Foundation

public class MarcoParsingError : Error {
    public let kind: ErrorKind
    public let offset: Int
    public let message: String
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

public class MarcoNonStrictParsingError : Error {
    public let errors: [MarcoParsingError]
    public let document: MarcoDocument
    
    public var localizedDescription: String {
        return errors.lazy.map { $0.localizedDescription }.joined()
    }

    internal init(errors: [MarcoParsingError], document: MarcoDocument) {
        self.errors = errors
        self.document = document
    }
}
