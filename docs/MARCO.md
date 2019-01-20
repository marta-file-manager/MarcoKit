# Marco syntax

This document is an informal explanation of Marco syntax.  
You can find the formal grammar [here](GRAMMAR.md).

## Motivation

Marco was created as a configuration file format for [Marta](https://marta.yanex.org), a macOS file manager. Previously, Marta used JSON, though it had a number of issues:

- Verbosity: enclosing '{}' for the root object, quoted object keys.
    - Harder to read and write.
    - Harder to make code insight features such as auto-formatting or completion.
- High ceremony: forbidden dangling commas.
    - Easier to make a mistake.

So I investigated what the alternatives are. However, surprisingly, I didn't find anything good enough. The most well-thought thing is [HOCON](https://github.com/lightbend/config/blob/master/HOCON.md#hocon-human-optimized-config-object-notation), though it has too many complex features, making it harder both to implement and use. Especially if the format is not well-known, its simplicity is a key for the good user experience.

So I started with JSON and removed all syntax that seemed impractical for the hand-written configuration files. I also added hexadecimal and color literals as they're pretty common in configs.

## Marco Features

- Clean syntax for writing configuration/data;
- Easily convertible to JSON and vice-versa;
- Two number types: `Int` and `Double`;
- Color and hexadecimal literals;
- Value escaping.

### Example

Here is an example of a simple Marco object:

```
{
    firstName "John"
    lastName "Smith"
    age 31
    city "New York"
    eyeColor #408002
    parents [
        {type "Father" firstName "Alex" lastName "Smith"}
        {type "Mother" firstName "Mary" lastName "Smith"}
    ]
}
```

As you may see, Marco looks pretty like JSON but without commas or colons. Object keys are not required to be string literals.

Marco does not insist on particular formatting rules. New lines are not required and you are free to format your document as you want. However, the default prettifier uses the four-space indentation for nested elements, and I recommend you to do so.

### Example (configuration object)

Marco supports a special kind of files -- configuration files. The only difference is that you do not need to enclose your keys in `{}`:

```
firstName "John"
lastName "Smith"
age 31
city "New York"
eyeColor #408002

parents [
    {type "Father" firstName "Alex" lastName "Smith"}
    {type "Mother" firstName "Mary" lastName "Smith"}
]
```

### Marco Types

Marta has 7 types or values: `Int`, `Double`, `String`, `Boolean`, `Array`, `Object`, and `Null`.

- `Int` is a signed integer type. Bounds may vary in different implementations. Minimal allowed bound is a native word size.
    - Decimal literals: `0`, `-5`, `10000`.
    - Hexadecimal literals: `0xff`, `0xABCDEF`. Letter case does not matter.
    - Color literals: `#AARRGGBB`, `#RRGGBB` or `#RGB` (parsed as `#RRGGBB`). `A` means 'alpha' (opacity), `R` means 'red', `G` means 'green', `B` means 'blue'.
- `Double` is a double-precision floating-point type.
    - Decimal literals: `5`, `5.0`, `1E-6`.
    - A number literal is always parsed as `Int` unless it contains a dot `.` or `E`/`e`.
- `String` is a UTF-8 string type. Strings can contain any symbols, including zero symbol. Strings are enclosed in double quotes.
    - Simple strings: `"Hello, world"`, `""`, `"おはよう"`.
    - Allowed escape sequences:
        - `\n`, `\t`, `\r`: `"New\nline"`.
        - `\"` for escaping `"`, `\\` for escaping `\`.
        - `\uABCD` for a Unicode characters (U+0000 through U+FFFF). `\u0008` is a backspace symbol, `\u0041` is "A".
- `Boolean`: `true` or `false`.
- `Array`: an iterable list of elements.  
Format: `[<element1> <element2> ... <elementN>]`.
    - `[]` is an empty array.
    - `[1 "foo"]` is an array containing two elements of different types, `1`: Int and `"foo"`: String.
    - `[[1] [2]]` is an array containing two nested arrays.
    - There must be at least a single whitespace symbol between the elements. `["foo"4]` is not a correct array.
- `Object` is a key-value map. A key is a `String` literal or an identifier.  
Format: `[<key1> <element1> ... <keyN> <elementN>]`.
    - Key may be an identifier if it starts with a letter, `$` or `_`, and all other characters are letters, numbers, `$`, `_` or `.`. `foo5` is a valid identifier, `5foo` is not.
    - Keys `"foo"`, `foo`, and `"\u0066\u006F\u006F"` are the same.
    - Keys "foo" and "Foo" are the different keys.
    - Duplicated keys are prohibited.
    - `{}` is an empty object.
    - `{a "foo" "b" 3}` is an object containing two key-value pairs. `a` is mapped to `"foo"`: String, `b` is mapped to `3`: Int.
    - There must be at least a single whitespace symbol between the key-value pairs and after the key.
- `Null` type represents a lack of value: `null`.

### Value Escaping

You can comment out a value by adding the leading `!`:

```
{
    firstName "John"
    lastName "Smith"
    !age 31
    age 32
    parents [
        !{type "Father" firstName "Alex" lastName "Smith"}
        {type "Mother" firstName "Mary" lastName "Smith"}
    ]
}
```

In the snippet above the key-value pair `age 31` and the "Father" parent array element are commented. Note that, although being escaped, the values are still parsed so they can't contain syntax errors.

Keys in escaped key-value pairs can be duplicated. This allows you to comment one value and replace it with an another. Note that this doesn't affect the escaped value structure: escaped objects still can't contain duplicate keys.