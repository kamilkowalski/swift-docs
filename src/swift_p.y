%{
#include "docgen.h"
#include <stdio.h>
extern void yyerror(char* errmsg);
extern int yylex();
%}
%token <sval> IDENTIFIER
%token AND ARROW ASSIGN BOOLEAN BREAK CASE CLASS COMPARISON CONTINUE DEFAULT DYNAMIC ELSE
%token FINAL FLOAT FOR FUNC GET GUARD IF IMPORT IN INT LET NOT OR OVERRIDE
%token PRIVATE PUBLIC REPEAT RETURN SET STATIC STRING SWITCH THROW TRY VAR WHILE

%union {
  char* sval;
}
%%
document: /* nothing */
        | statements
        ;
statements: statement
          | statements statement
          ;
statement: expression
         | declaration
         | loop_statement
         | branch_statement
         | control_transfer_statement
         ;
loop_statement: for_in_statement
              | while_statement
              | repeat_while_statement
              ;
for_in_statement: FOR IDENTIFIER IN expression code_block
                ;
while_statement: WHILE condition code_block
               ;
repeat_while_statement: REPEAT code_block WHILE condition
                      ;
condition: expression
         | optional_binding_condition
         ;
optional_binding_condition: LET IDENTIFIER initializer
                          | VAR IDENTIFIER initializer
                          ;
initializer: ASSIGN expression
           ;
branch_statement: if_statement
                | guard_statement
                | switch_statement
                ;
if_statement: IF condition code_block else_clause
            | IF condition code_block
            ;
else_clause: ELSE code_block
           | ELSE if_statement
           ;
guard_statement: GUARD condition ELSE code_block
               ;
switch_statement: SWITCH expression '{' switch_cases '}'
                ;
switch_cases: switch_case
            | switch_case switch_cases
            ;
switch_case: case_label statements
           | default_label statements
           ;
case_label: CASE case_item_list ':'
          ;
case_item_list: IDENTIFIER
              | IDENTIFIER ',' case_item_list
              ;
default_label: DEFAULT ':'
             ;
control_transfer_statement: BREAK
                          | CONTINUE
                          | return_statement
                          | throw_statement
                          ;
return_statement: RETURN
                | RETURN expression
                ;
throw_statement: THROW expression
               ;
expression: try_operator prefix_expression binary_expressions
          | try_operator prefix_expression
          | prefix_expression binary_expressions
          | prefix_expression
          ;
try_operator: TRY '?'
            | TRY '!'
            | TRY
            ;
prefix_expression: prefix_operator postfix_expression
                 | postfix_expression
                 ;
binary_expression: binary_operator prefix_expression
                 | ASSIGN try_operator prefix_expression
                 | ASSIGN prefix_expression
                 | conditional_operator try_operator prefix_expression
                 | conditional_operator prefix_expression
                 ;
binary_expressions: binary_expression
                  | binary_expressions binary_expression
                  ;
operator: '*'
        | '/'
        | '+'
        | '-'
        | '%'
        | '^'
        | '!'
        ;
binary_operator: operator
               ;
prefix_operator: operator
               ;
primary_expression: literal_expression
                  | IDENTIFIER
                  ;
literal_expression: literal
                  | array_literal
                  | dictionary_literal
                  ;
array_literal: '[' ']'
             | '[' array_literal_items ']'
             ;
array_literal_items: array_literal_item
                   | array_literal_item ',' array_literal_items
                   ;
array_literal_item: expression
                  ;
dictionary_literal: '[' ':' ']'
                  | '[' dictionary_literal_items ']'
                  ;
dictionary_literal_items: dictionary_literal_item
                        | dictionary_literal_item ',' dictionary_literal_items
                        ;
dictionary_literal_item: expression ':' expression
                       ;
conditional_operator: '?' try_operator expression ':'
                    | '?' expression ':'
                    ;
postfix_expression: primary_expression
                  | function_call_expression
                  ;
function_call_expression: IDENTIFIER function_call_arguments_clause
                        ;
function_call_arguments_clause: '(' ')'
                              | '(' function_call_arguments ')'
                              ;
function_call_arguments: function_call_argument
                       | function_call_argument ',' function_call_arguments
                       ;
function_call_argument: expression
                      | IDENTIFIER ':' expression
                      ;
declarations: declaration
            | declaration declarations
            ;
declaration: import_declaration
           | constant_declaration
           | variable_declaration
           | function_declaration
           | class_declaration
           ;
import_declaration: IMPORT IDENTIFIER
                  ;
constant_declaration: declaration_modifiers LET pattern_initializer
                    | LET pattern_initializer
                    ;
pattern_initializer: pattern initializer
                   | pattern
                   ;
pattern: wildcard_pattern type_annotation
       | IDENTIFIER type_annotation
       | wildcard_pattern
       | IDENTIFIER
       ;
wildcard_pattern: '_'
                ;
declaration_modifiers: declaration_modifier
                     | declaration_modifier declaration_modifiers
                     ;
declaration_modifier: access_level_modifier
                    | CLASS
                    | DYNAMIC
                    | FINAL
                    | OVERRIDE
                    | STATIC
                    ;
access_level_modifier: PRIVATE
                     | PUBLIC
                     ;
variable_declaration: variable_declaration_head pattern_initializer
                    | variable_declaration_head IDENTIFIER type_annotation code_block
                    | variable_declaration_head IDENTIFIER type_annotation getter_setter_block
                    ;
variable_declaration_head: declaration_modifiers VAR
                         | VAR
                         ;
type_annotation: ':' type
               ;
getter_setter_block: '{' getter_clause setter_clause '}'
                   | '{' getter_clause '}'
                   | '{' setter_clause getter_clause '}'
                   ;
getter_clause: GET code_block
             ;
setter_clause: SET code_block
             ;
function_declaration: function_head IDENTIFIER function_signature function_body
                    | function_head IDENTIFIER function_signature
                    ;
function_head: declaration_modifiers FUNC
             | FUNC
             ;
function_signature: parameter_clause function_result
                  | parameter_clause
                  ;
parameter_clause: '(' ')'
                | '(' parameter_list ')'
                ;
parameter_list: parameter
              | parameter ',' parameter_list
              ;
parameter: external_parameter_name local_parameter_name type_annotation default_argument_clause
         | external_parameter_name local_parameter_name type_annotation
         | local_parameter_name type_annotation
         ;
external_parameter_name: IDENTIFIER
                       ;
local_parameter_name: IDENTIFIER
                    ;
default_argument_clause: ASSIGN expression
                       ;
function_result: ARROW type
               ;
function_body: code_block
             ;
class_declaration: access_level_modifier CLASS class_name class_inheritance_clause class_body
                 | access_level_modifier CLASS class_name class_body
                 | CLASS class_name class_inheritance_clause class_body
                 | CLASS class_name class_body
                 ;
class_name: IDENTIFIER
          ;
class_inheritance_clause: ':' IDENTIFIER
                        ;
class_body: '{' '}'
          | '{' declarations '}'
          ;
code_block: '{' '}'
          | '{' statements '}'
          ;
type: array_type
    | dictionary_type
    | optional_type
    | IDENTIFIER
    ;
array_type: '[' type ']'
          ;
dictionary_type: '[' type ':' type ']'
               ;
optional_type: type '?'
             ;
literal: STRING
       | INT
       | FLOAT
       ;

%%
int main(int argc, char** argv) {
  extern FILE* yyin;
  char* source = argv[1];
  printf("Parsing file %s\n", source);
  yyin=fopen(source, "r");
  yyparse();

  return 0;
}
