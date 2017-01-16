%{
  #include "swift_p.h"
  #include <stdio.h>
  int lineno = 1;
  void yyerror(char* s);
%}
%%
import                  { return IMPORT; }
class                   { return CLASS; }
dynamic                 { return DYNAMIC; }
var                     { return VAR; }
let                     { return LET; }
if                      { return IF; }
else                    { return ELSE; }
return                  { return RETURN; }
func                    { return FUNC; }
override                { return OVERRIDE; }
static                  { return STATIC; }
true |
false                   { return BOOLEAN; }
"||"                    { return OR; }
"&&"                    { return AND; }
"!"                     { return NOT; }
[a-zA-Z_][a-zA-Z0-9_-]* { return IDENTIFIER; }
"=="  |
"<>"  |
"<"   |
">"   |
"<="  |
">="                    { return COMPARISON; }
"="                     { return ASSIGN; }
"->"                    { return ARROW; }
[\+\-\*/\?:\(\)\{\}\[\]\.\;]        { return yytext[0]; }
[0-9]+                  { return INT; }
[0-9]+"."[0-9]+ |
"."[0-9]+               { return FLOAT; }
"\""[^\"]*"\"" |
'[^']*'                 { return STRING; }
\/\/.*$                   /* Comment */
%%

void yyerror(char* s) {
  printf("%d: %s at %s\n", lineno, s, yytext);
}
