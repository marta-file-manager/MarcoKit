import Foundation

func printErr(_ message: String) {
    var standardError = FileHandle.standardError
    print(message, to: &standardError)
}

extension FileHandle : TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}
