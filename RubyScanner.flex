%%

%class RubyLexer 
%unicode
%public
%type Token

%eofval{
    return new Token(TokenType.EOF);
%eofval}

%{
    StringBuffer string = new StringBuffer();
%}

/* main character classes */
LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]

WhiteSpace = {LineTerminator} | [ \t\f]+

/* comments */
Comment = "#" {InputCharacter}* {LineTerminator}?

/* identifiers */
Identifier = [a-zA-Z][a-zA-Z0-9_]*

/* operators */
OPERATOR = "." |"+" | "-" | "*" | "/" | "=" | "==" | "!=" | "<" | ">" | "<=" | ">=" | "&&" | "||" | "!" | "<<" | ">>" | "&" | "|" 
          | "^" | "~" | "+=" | "-=" | "*=" | "/=" | "%=" | "<<=" | ">>=" | "&=" | "^=" | "|=" | "&&=" | "||=" | "**" | "**=" | "%"| "?"
GLOBAL = "$"

/* integer  */
DecIntegerLiteral = 0 | [1-9][0-9]*
DecLongLiteral    = {DecIntegerLiteral} [lL]

HexIntegerLiteral = 0 [xX] 0* {HexDigit} {1,8}
HexLongLiteral    = 0 [xX] 0* {HexDigit} {1,16} [lL]
HexDigit          = [0-9a-fA-F]

OctIntegerLiteral = 0+ [1-3]? {OctDigit} {1,15}
OctLongLiteral    = 0+ 1? {OctDigit} {1,21} [lL]
OctDigit          = [0-7]
    
/* floating point */        
FloatLiteral  = ({FLit1}|{FLit2}|{FLit3}) {Exponent}? [fF]
DoubleLiteral = ({FLit1}|{FLit2}|{FLit3}) {Exponent}?

FLit1    = [0-9]+ \. [0-9]* 
FLit2    = \. [0-9]+ 
FLit3    = [0-9]+ 
Exponent = [eE] [+-]? [0-9]+


/* string and character literals */
StringCharacter = [^\r\n\"\\]

%state STRING

%%

<YYINITIAL> {

  /* keywords */
  "BEGIN"                        |
  "ensure"                       |
  "assert"                       |
  "nil"                          |
  "self"                         |
  "when"                         |
  "END"                          |
  "false"                        |
  "not"                          |
  "super"                        |
  "alias"                        |
  "defined"                      |
  "or"                           |
  "then"                         |
  "yield"                        |
  "and"                          |
  "redo"                         |
  "true"                         |
  "else"                         |
  "in"                           |
  "rescue"                       |
  "undef"                        |
  "break"                        |
  "elsif"                        |
  "module"                       |
  "retry"                        |
  "unless"                       |
  "next"                         |
  "return"                       { return new Token(TokenType.KEYWORD,yytext()); }

  "begin"                        |
  "case"                         |
  "class"                        |
  "def"                          |
  "for"                          |
  "while"                        |
  "until"                        |
  "do"                           |
  "if"                           { return new Token(TokenType.KEYWORD,  yytext()); }

  "end"                          { return new Token(TokenType.KEYWORD, yytext()); }


  /* Built-in Types*/
  "self"                         |
  "nil"                          |
  "true"                         |
  "false"                        |
  "__FILE__"                     |
  "__LINE__"                     {  return new Token(TokenType.TYPE);  }

<YYINITIAL> {
  \"                             {
                                  yybegin(STRING);
                                  string.setLength(0);}
  /* operators */
  {OPERATOR}                     { return new Token(TokenType.OPERATOR, yytext()); }
  {GLOBAL}                       { return new Token(TokenType.GLOBAL, yytext());}
  /* delimiters */
  "("                            { return new Token(TokenType.LEFT_PAREN);}
  ")"                            { return new Token(TokenType.RIGHT_PAREN);}
  "{"                            { return new Token(TokenType.LEFT_CURLY);}
  "}"                            { return new Token(TokenType.RIGHT_CURLY); }
  "["                            { return new Token(TokenType.LEFT_BRACKET); }
  "]"                            { return new Token(TokenType.RIGHT_BRACKET); }
  "@"                            { return new Token(TokenType.INSTANCE); }
  ","                            { return new Token(TokenType.COMMA); }
  ";"                            { return new Token(TokenType.SEMICOLON); }
  ":"                            { return new Token(TokenType.COLON); }
  "`"                            { return new Token(TokenType.BACKTICK); }
  
}


  /* numeric literals */
  {DecIntegerLiteral}            |
  {DecLongLiteral}               |
  
  {HexIntegerLiteral}            |
  {HexLongLiteral}               |
 
  {OctIntegerLiteral}            |
  {OctLongLiteral}               |

  {FloatLiteral}                 |
  {DoubleLiteral}                |
  {FloatLiteral}[jJ]             { return new Token(TokenType.NUMBER,yytext()); }
  
  /* comments */
  {Comment}                      {/* ignore */ }

  /* whitespace */
  {WhiteSpace}                   { /* ignore */}

  /* identifiers */ 
  {Identifier}"?"                { return new Token(TokenType.TYPE2,yytext()); }
  {Identifier}                   { return new Token(TokenType.IDENTIFIER,yytext()); }
}

<STRING> {
  \"                             { 
                                     yybegin(YYINITIAL); 
                                     // length also includes the trailing quote
                                     return new Token(TokenType.STRING, string.toString());
                                 }
  
  {StringCharacter}+             { string.append(yytext()); }

  \\[0-3]?{OctDigit}?{OctDigit}  { string.append(yytext()) ;}
  
  /* escape sequences */

  \\.                            { string.append(yytext());}
  {LineTerminator}               { string.append(yytext()) ;}
}

/* error fallback */
[^]                              { throw new Error("Illegal character <"+yytext()+">"); }

//public boolean yyatEOF() {return zzAtEOF;}