%{
#include "tree.h"
#include "swift_p.h"
#include <stdio.h>
#include <string.h>
void yyerror(char* s);
void copy_string_value();
%}
%%
\n                            { yylineno++; }
case                          { return CASE; }
class                         { return CLASS; }
default                       { return DEFAULT; }
dynamic                       { return DYNAMIC; }
else                          { return ELSE; }
for                           { return FOR; }
func                          { return FUNC; }
get                           { return GET; }
guard                         { return GUARD; }
if                            { return IF; }
in                            { return IN; }
import                        { return IMPORT; }
let                           { return LET; }
override                      { return OVERRIDE; }
private                       { return PRIVATE; }
public                        { return PUBLIC; }
repeat                        { return REPEAT; }
return                        { return RETURN; }
set                           { return SET; }
static                        { return STATIC; }
switch                        { return SWITCH; }
try                           { return TRY; }
var                           { return VAR; }
while                         { return WHILE; }

true |
false                         { return BOOLEAN; }
"||"                          { return OR; }
"&&"                          { return AND; }
"!"                           { return NOT; }
[a-zA-Z_][a-zA-Z0-9_-]*       { copy_string_value(); return IDENTIFIER; }
"=="  |
"<>"  |
"<"   |
">"   |
"<="  |
">="                          { return COMPARISON; }
"="                           { return ASSIGN; }
"->"                          { return ARROW; }
[_/=\-\+!\*%<>&|^~?]          { return yytext[0]; }
[:\(\)\{\}\[\]\.\,\;]         { return yytext[0]; }
[0-9]+                        { return INT; }
[0-9]+"."[0-9]+ |
"."[0-9]+                     { return FLOAT; }
"\""[^\"]*"\""                { copy_string_value(); return STRING; }
\/\/.*$                       /* comment */
.|\n                          /* whitespace */
%%

void yyerror(char* s) {
  printf("%d: %s at %s\n", yylineno, s, yytext);
}

void copy_string_value() {
  yylval.sval = (char*)malloc(yyleng+1);
  strcpy(yylval.sval, yytext);
}
