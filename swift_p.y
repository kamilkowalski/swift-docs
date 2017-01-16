%{
#include <stdio.h>
%}
%token IDENTIFIER STRING INT FLOAT
%token COMPARISON AND OR NOT BOOLEAN
%token ASSIGN ARROW
%token IMPORT CLASS DYNAMIC VAR LET IF ELSE RETURN
%token FUNC OVERRIDE STATIC
%%
lines: line
     | lines line
     ;
line: '\n'
    | import_def
    | expr
    ;
exprs: /* nothing */
     | expr
     | exprs expr
     ;
expr: class_def
    | func_def
    ;
import_def: IMPORT IDENTIFIER
          ;
class_def: class_identifier '{' exprs '}'
         ;
class_identifier: CLASS IDENTIFIER
                | CLASS IDENTIFIER ':' IDENTIFIER
func_def: func_spec FUNC IDENTIFIER func_return '{' exprs '}'
        ;
func_spec: /* nothing */
         | OVERRIDE
         | STATIC
         | OVERRIDE STATIC
         ;
func_return: /* nothing */
           | ARROW type
           ;
type: IDENTIFIER
    | '[' type ']'
    | '[' type ':' type ']'
    | type '?'
    ;
%%
int main() {
  yyparse();
}
