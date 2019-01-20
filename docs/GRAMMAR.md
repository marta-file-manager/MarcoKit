# Marco Grammar

This file contains a formal grammar description of the Marco syntax.  

## Legend

`foo?` means "zero or one occurrences of `foo`".  
`foo*` means zero or more occurrences of `foo`".  
`foo+` means "one or more occurrences of `foo`".  
`foo[<num>]` means "exactly &lt;num&gt; occurrences of `foo`".  
`'<ch1>' | '<ch2>' | ... | '<chN>'` means "any of the described strings".

## Predefined symbols

`<Letter>` = Any Unicode character from Unicode categories L* and M*.  
`<Unescaped>` = Any Unicode character excluding : U+0020 (Space), U+0009 (Horizontal Tab), U+000A (New Line) or U+000D (Carriage Return).

## Grammar

- The input text must be encoded using UTF-8.
- A byte order mark **must not** be present in the beginning of the input text.
- Recommended file extension: `.marco`.
- Recommended MIME type: `application/marco`.

<pre>
ValueFile (root)
  : Whitespace*, Value, Whitespace*

ConfigurationFile (root)
  : Whitespace*
  : Whitespace*, KeyValuePairs, Whitespace*

Value
  : IntLiteral
  : DoubleLiteral
  : StringLiteral
  : BooleanLiteral
  : NullLiteral
  : Array
  : Object

IntLiteral
  : RegularIntLiteral
  : HexLiteral
  : ColorLiteral

RegularIntLiteral
  : PositiveRegularIntLiteral
  : '-', PositiveRegularIntLiteral

PositiveRegularIntLiteral
  : Digit
  : OneNine, Digit*

HexLiteral
  : '0x', HexDigit*
  : '-', '0x', HexDigit*

ColorLiteral
  : '#', HexDigit[3]
  : '#', HexDigit[6]
  : '#', HexDigit[8]

DoubleLiteral
  : RegularIntLiteral, '.', PositiveRegularIntLiteral
  : RegularIntLiteral, '.', PositiveRegularIntLiteral, 'e' | 'E', PositiveRegularIntLiteral

StringLiteral
  : '"', Character*, '"'

Character
  : '\', 'n' | 't' | 'r' | '\', '"'
  : '\u', HexDigit[4]
  : &lt;Unescaped&gt;

BooleanLiteral
  : 'true' | 'false'

NullLiteral
  : 'null'

Array
  : '[', Whitespace*, ']'
  : '[', Whitespace*, Elements, Whitespace*, ']'

Elements
  : '!'?, Value
  : '!'?, Value, Whitespace*, Elements

Object
  : '{', Whitespace*, '}'
  : '{', Whitespace*, KeyValuePairs, Whitespace*, '}'

KeyValuePairs
  : '!'?, KeyValuePair
  : '!'?, KeyValuePair, Whitespace+, KeyValuePairs

KeyValuePair
  : Key, Whitespace+, Value

Key
  : Identifier
  : StringLiteral

Identifier
  : IdentifierStart, IdentifierRemaining*

IdentifierStart
  : &lt;Letter&gt;
  : '$' | '_'

IdentifierRemaining
  : &lt;Letter&gt;
  : Digit
  : '$' | '_'

OneNine
  : '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'

Digit
  : '0'
  : OneNine

HexDigit
  : Digit
  : 'A' | 'a' | 'B' | 'b' | 'C' | 'c' | 'D' | 'd' | 'E' | 'e' | 'F' | 'f'

Whitespace
  : U+0020 (Space)
  : U+0009 (Horizontal Tab)
  : U+000A (New Line)
  : U+000D (Carriage Return)
</pre>