import Foundation

internal struct Args {
    var command: String
    var args: [String]
    var options: [String]
}

internal func parseArgs(rawArgs: [String]) -> Args? {
    guard !rawArgs.isEmpty else { return nil }
    let command = rawArgs[0]
    var args = [String]()
    var options = [String]()
    
    for rawArg in rawArgs.dropFirst() {
        if (rawArg.hasPrefix("--")) {
            options.append(String(rawArg.dropFirst(2)))
        } else {
            args.append(rawArg)
        }
    }
    
    return Args(command: command, args: args, options: options)
}
