/*
 * htl-parser 1.0.0
 * Copyright (c) 2018 Lachlan McDonald
 * https://github.com/lachlanmcdonald/htl-parser/
 *
 * Licensed under the BSD 3-Clause license.
 */

Grammar
    = e:Expression PlainText* { return e; }

PlainText
    = chars:$(!'${'.)+ { return chars; }

Expression
    = ExpressionStart expression:Node? options:(OptionsSeparator OptionList)? ExpressionEnd {
        return ['expression', {
            expression,
            options: (options ? options[1]: []),
            location: location()
        }];
    }

ArrayStart       = '[' w*
ArrayEnd         = w* ']'
CommaSeperated   = w* ',' w*
ExpressionStart  = '${' w*
ExpressionEnd    = w* '}'
Not              = '!' w*
OptionsSeparator = w* '@' w*
ParenthesesStart = '(' w*
ParenthesesEnd   = w* ')'
TernaryIf        = w '?' w
TernaryElse      = w ':' w

OptionList 'option list'
   = a:Option b:(CommaSeperated Option)* { return [a].concat(b.map(x => x[1])); }

Option 'option'
    = v:Variable x:(w* '=' w* Node)? {
        return ['option', {
            option: v[1],
            value: (x === null ? null : x[3])
        }];
    }

Node "expression"
    = comparison:BinaryOperator TernaryIf left:BinaryOperator TernaryElse right:BinaryOperator { return ['ternary', {comparison, left, right}]; }
    / BinaryOperator

BinaryOperator
    = left:Factor w* operator:Operator w* right:Factor { return ['comparison', {left, operator, right}]; }
    / Factor

Operator "operator"
    = '&&' { return 'and'; }
    / '||' { return 'or'; }
    / '<=' { return 'lte'; }
    / '<'  { return 'lt'; }
    / '>'  { return 'gt'; }
    / '==' { return 'equal'; }
    / '!=' { return 'not_equal'; }

Factor
    = not:Not? term:Term { return ['factor', {negative: !!not, term}] }

Term
    = ParenthesesStart e:Node ParenthesesEnd { return ['expression', e]; }
    / Property

Property
    = atom:Atom accessors:PropertyAccess* {
        return ['property', {
            atom,
            accessors: [].concat.apply([], accessors)
        }];
    }

PropertyAccess
    = accessors:('.' Field)+                { return accessors.map(x => x[1]); }
    / accessors:(ArrayStart Node ArrayEnd)+ { return accessors.map(x => x[1]); }

Field
    = Variable

Atom
    = Array
    / Float
    / Integer
    / Boolean
    / Variable
    / String

Array "array"
    = ArrayStart ArrayEnd { return ['array', []]; }
    / ArrayStart a:ArrayItem b:(CommaSeperated ArrayItem)* ArrayEnd {
        let firstItem = [a];
        let otherItems = (b || []).map(x => x[1]);
        return ['array', [].concat(firstItem, otherItems) ];
    }

ArrayItem "array item"
    = Atom
    / Node

Boolean "boolean"
    = b: 'true'  { return ['boolean', b === 'true']; }
    / b: 'false' { return ['boolean', b === 'true']; }

Variable "variable"
    = v: $([a-zA-Z_][a-zA-Z0-9_:]*) { return ['variable', v]; }

Float 'float'
    = f: $([0-9]+ '.' [0-9]* exponent?) { return ['float', parseFloat(f)]; }
    / f: $('.' [0-9]+ exponent?)        { return ['float', parseFloat(f)]; }
    / f: $([0-9]+ exponent)             { return ['float', parseFloat(f)]; }

exponent 'exponent'
    = $([eE][+-]?[0-9]+)

Integer "integer"
    = v: $([0-9]+) { return ['integer', parseInt(v, 10) ]; }

String "string"
    = '"' chars:DoubleStringCharacter* '"' { return ['string', chars.join('')]; }
    / "'" chars:SingleStringCharacter* "'" { return ['string', chars.join('')]; }

DoubleStringCharacter
    = !('"' / "\\") char:. { return char; }
    / "\\" sequence:Escape { return sequence; }

SingleStringCharacter
    = !("'" / "\\") char:. { return char; }
    / "\\" sequence:Escape { return sequence; }

Escape
    = "'"
    / '"'
    / "\\"
    / "b" { return "\b"; }
    / "f" { return "\f"; }
    / "n" { return "\n"; }
    / "r" { return "\r"; }
    / "t" { return "\t"; }
    / UnicodeEscape
    / OctalEscape

UnicodeEscape
    = $('\\u' HexDigit{4})

OctalEscape
    = $('\\' [0-3][0-7]{1,2})
    / $('\\' [0-7]{1,2})

HexDigit
    = [0-9a-fA-F]

w 'whitespace'
    = [\u0020\t\r\n\u000B\u00A0]+
