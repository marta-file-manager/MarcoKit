import Foundation

fileprivate func printUsage() {
    print("Usage:")
    print("marco j2m <file> – convert JSON to Marco")
    print("marco m2j <file> – convert Marco to Json")
}

fileprivate func cli() {
    guard
        let args = parseArgs(rawArgs: Array(CommandLine.arguments.dropFirst())),
        args.args.count == 1
    else {
        printUsage()
        return
    }
    
    let path = args.args[0]
    let isConfig = args.options.contains("config")
    let fn: (String, Bool) -> ()
    
    switch (args.command) {
        case "j2m": fn = jsonToMarco
        case "m2j": fn = marcoToJson
        default:
            printUsage()
            return
    }
    
    fn(path, isConfig)
}

private func jsonToMarco(path: String, isConfig: Bool) {
    let jsonObject: Any
    
    do {
        let text = readFile(path: path)
        guard let data = text.data(using: .utf8) else {
            printErr("Only UTF-8 JSON files are supported")
            exit(1)
        }
        jsonObject = try JSONSerialization.jsonObject(with: data)
    } catch let e {
        printErr("Unable to parse JSON document: \(e.localizedDescription)")
        exit(1)
    }
    
    let marco: MarcoDocument
    if (isConfig) {
        guard let obj = jsonObject as? [String: Any] else {
            printErr("JSON value is not an object, can't generate a Marco config")
            exit(1)
        }
        
        marco = Marco.configFromJson(object: obj)
    } else {
        marco = Marco.fromJson(object: jsonObject)
    }
    
    print(Marco.prettify(marco), terminator: "")
}

private func marcoToJson(path: String, isConfig: Bool) {
    let marco: MarcoDocument
    
    do {
        let options: Marco.Options = isConfig ? .config : []
        marco = try Marco.parse(readFile(path: path), options: options)
    } catch let e {
        printErr("Unable to parse Marco document: \(e.localizedDescription)")
        exit(1)
    }
    
    print(Marco.toJsonString(marco), terminator: "")
}

private func readFile(path: String) -> String {
    do {
        return try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
    } catch let e {
        printErr("Unable to read file '\(path)': \(e.localizedDescription)")
        exit(1)
    }
}

cli()
