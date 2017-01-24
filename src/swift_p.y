%{
#include "tree.h"
#include "shell_formatter.h"
#include <stdio.h>
extern void yyerror(char* errmsg);
extern int yylex();
void cl_make_switch(char* name);

Node* root_node;
Node* current_node;

%}
%token <sval> IDENTIFIER
%token AND ARROW ASSIGN BOOLEAN BREAK CASE CLASS COMPARISON CONTINUE DEFAULT DYNAMIC ELSE
%token FINAL FLOAT FOR FUNC GET GUARD IF IMPORT IN INT LET NOT OR OVERRIDE
%token PRIVATE PUBLIC REPEAT RETURN SET STATIC STRING SWITCH THROW TRY VAR WHILE

%type <fval> function_signature
%type <nval> constant_declaration function_declaration variable_declaration
%type <sval> class_name wildcard_pattern external_parameter_name local_parameter_name
%type <prval> parameter_clause parameter_list parameter
%type <pval> pattern pattern_initializer
%type <tval> array_type dictionary_type optional_type type type_annotation function_result

%union {
  Function* fval;
  Node* nval;
  Param* prval;
  Pattern* pval;
  Type* tval;
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
           | constant_declaration { append_node(current_node, $1); }
           | variable_declaration { append_node(current_node, $1); }
           | function_declaration { append_node(current_node, $1); }
           | class_declaration { current_node = current_node->parent; }
           ;
import_declaration: IMPORT IDENTIFIER
                  ;
constant_declaration: declaration_modifiers LET pattern_initializer {
                      $$ = make_node(N_CONSTANT, $3->name, $3->type);
                    }
                    | LET pattern_initializer { $$ = make_node(N_CONSTANT, $2->name, $2->type); }
                    ;
pattern_initializer: pattern initializer { $$ = $1; }
                   | pattern { $$ = $1; }
                   ;
pattern: wildcard_pattern type_annotation { $$ = make_full_pattern($1, $2); }
       | IDENTIFIER type_annotation { $$ = make_full_pattern($1, $2); }
       | wildcard_pattern { $$ = make_pattern($1); }
       | IDENTIFIER { $$ = make_pattern($1); }
       ;
wildcard_pattern: '_' { $$ = "_"; }
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
variable_declaration: variable_declaration_head pattern_initializer {
                      $$ = make_node(N_VARIABLE, $2->name, $2->type);
                    }
                    | variable_declaration_head IDENTIFIER type_annotation code_block {
                      $$ = make_node(N_VARIABLE, $2, $3);
                    }
                    | variable_declaration_head IDENTIFIER type_annotation getter_setter_block {
                      $$ = make_node(N_VARIABLE, $2, $3);
                    }
                    ;
variable_declaration_head: declaration_modifiers VAR
                         | VAR
                         ;
type_annotation: ':' type { $$ = $2; }
               ;
getter_setter_block: '{' getter_clause setter_clause '}'
                   | '{' getter_clause '}'
                   | '{' setter_clause getter_clause '}'
                   ;
getter_clause: GET code_block
             ;
setter_clause: SET code_block
             ;
function_declaration: function_head IDENTIFIER function_signature function_body {
                      $$ = make_node(N_FUNCTION, $2, $3);
                    }
                    | function_head IDENTIFIER function_signature {
                      $$ = make_node(N_FUNCTION, $2, $3);
                    }
                    ;
function_head: declaration_modifiers FUNC
             | FUNC
             ;
function_signature: parameter_clause function_result { $$ = make_function($1, $2); }
                  | parameter_clause { $$ = make_function($1, (Type*)0); }
                  ;
parameter_clause: '(' ')' { $$ = (Param*)0; }
                | '(' parameter_list ')' { $$ = $2; }
                ;
parameter_list: parameter { $$ = $1; }
              | parameter ',' parameter_list { $1->next = $3; $$ = $1;  }
              ;
parameter: external_parameter_name local_parameter_name type_annotation default_argument_clause {
          $$ = make_param($1, $2, $3);
         }
         | external_parameter_name local_parameter_name type_annotation { $$ = make_param($1, $2, $3); }
         | local_parameter_name type_annotation { $$ = make_param((char*)0, $1, $2); }
         ;
external_parameter_name: IDENTIFIER { $$ = $1; }
                       ;
local_parameter_name: IDENTIFIER { $$ = $1; }
                    ;
default_argument_clause: ASSIGN expression
                       ;
function_result: ARROW type { $$ = $2; }
               ;
function_body: code_block
             ;
class_declaration: access_level_modifier CLASS class_name { cl_make_switch($3); } class_inheritance_clause class_body
                 | access_level_modifier CLASS class_name { cl_make_switch($3); } class_body
                 | CLASS class_name { cl_make_switch($2); } class_inheritance_clause class_body
                 | CLASS class_name { cl_make_switch($2); } class_body
                 ;
class_name: IDENTIFIER { $$ = $1 }
          ;
class_inheritance_clause: ':' IDENTIFIER
                        ;
class_body: '{' '}'
          | '{' declarations '}'
          ;
code_block: '{' '}'
          | '{' statements '}'
          ;
type: array_type { $$ = $1; }
    | dictionary_type { $$ = $1; }
    | optional_type { $$ = $1; }
    | IDENTIFIER { $$ = make_identifier_type($1); }
    ;
array_type: '[' type ']' { $$ = make_array_type($2); }
          ;
dictionary_type: '[' type ':' type ']' { $$ = make_dictionary_type($2, $4); }
               ;
optional_type: type '?' { $$ = make_optional_type($1); }
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

  root_node = make_node(N_ROOT, source, (void*)0);
  current_node = root_node;

  yyin=fopen(source, "r");
  yyparse();

  print_node_info(root_node, 0);

  return 0;
}

void cl_make_switch(char* name) {
  Node* cl = make_node(N_CLASS, name, (void*)0);
  append_node(current_node, cl);
  current_node = cl;
}
