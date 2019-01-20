# MarcoKit: Marco parsing library for Swift

This is a Swift library for working with Marco configuration/value files.  
Also, this is a reference implementation of the Marco parser.

## What is Marco?

Marco is a new configuration and data serialization format. You can read more about it [here](https://github.com/marta-file-manager/MarcoKit/blob/master/docs/MARCO.md).

## Library features

MarcoKit allows you to:

- Parse Marco value/configuration files;
- Modify and serialize documents back to `String` (formatting is preserved);
- Create new Marco documents;
- Minify or prettify Marco documents;
- Convert Marco to Objective-C representation of JSON and vice-versa.

## Carthage

MarcoKit can be imported as a [Carthage](https://github.com/Carthage/Carthage) dependency:

`github "marta-file-manager/MarcoKit" "v0.1"`

## Documentation

The API reference is available [here](https://marta-file-manager.github.io/MarcoKit/api/index.html).

## Performance 

While Marco syntax as easy to parse as JSON, MarcoKit backs Marco values with AST elements. This allows you to modify the document contents without losing the formatting and to implement code insight features. However, this comes as a cost of performance.

I didn't do any serious performance comparison with other serialization libraries, but the testing shows that using MarcoKit may not be the best idea if you have huge data chunks. However, the difference is unnoticeable for common configuration file use-cases.

## Contributing

MarcoKit is available under the [Apache 2.0 License](https://github.com/marta-file-manager/MarcoKit/blob/master/LICENSE).

If you send a Pull Request, please ensure that all existing tests are passing ("All Tests" scheme, Product → Test).  
If you fixed a bug, add the new test or modify the existing one to check the new behavior.  
If you plan to change the Marco format, consider making an issue describing your problem and a proposed solution.