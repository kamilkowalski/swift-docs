#include "shell_formatter.h"
#include <stdio.h>

void print_class_info(Node* class, int ilevel);
void print_constant_info(Node* constant, int ilevel);
void print_variable_info(Node* variable, int ilevel);
void print_function_info(Node* function, int ilevel);
void print_root_info(Node* root, int ilevel);
void print_children_info(Node* parent, int ilevel);
void print_node_type(Node* typable, int ilevel);
void print_type(Type* type);
void log_indent(char* string, int level);
void indent(int level);

void print_node_info(Node* node, int ilevel) {
  switch(node->type) {
    case N_CLASS:
      print_class_info(node, ilevel);
      break;
    case N_CONSTANT:
      print_constant_info(node, ilevel);
      break;
    case N_FUNCTION:
      print_function_info(node, ilevel);
      break;
    case N_ROOT:
      print_root_info(node, ilevel);
      break;
    case N_VARIABLE:
      print_variable_info(node, ilevel);
      break;
  }
}

void print_class_info(Node* class, int ilevel) {
  log_indent("Class node", ilevel);
  log_indent("Name:", ilevel+1);
  log_indent(class->name, ilevel+2);
  print_children_info(class, ilevel+1);
}

void print_constant_info(Node* constant, int ilevel) {
  log_indent("Constant node", ilevel);
  log_indent("Name:", ilevel+1);
  log_indent(constant->name, ilevel+2);
  print_node_type(constant, ilevel+1);
}

void print_variable_info(Node* variable, int ilevel) {
  log_indent("Variable node", ilevel);
  log_indent("Name:", ilevel+1);
  log_indent(variable->name, ilevel+2);
  print_node_type(variable, ilevel+1);
}

void print_function_info(Node* function, int ilevel) {
  log_indent("Function node", ilevel);
  log_indent("Name:", ilevel+1);
  log_indent(function->name, ilevel+2);
}

void print_root_info(Node* root, int ilevel) {
  log_indent("Root node", ilevel);
  log_indent("Name:", ilevel+1);
  log_indent(root->name, ilevel+2);
  print_children_info(root, ilevel+1);
}

void print_children_info(Node* parent, int ilevel) {
  if (parent->first_child) {
    log_indent("Children:", ilevel);
    Node* current = parent->first_child;

    while(current) {
      print_node_info(current, ilevel+1);
      current = current->next;
    }
  }
}

void print_node_type(Node* typable, int ilevel) {
  if (typable->meta) {
    log_indent("Type:", ilevel);
    indent(ilevel+1);
    print_type((Type*) typable->meta);
    puts("");
  }
}

void print_type(Type* type) {
  switch(type->category) {
    case T_ARRAY:
      putchar('[');
      print_type(type->item_type);
      putchar(']');
      break;
    case T_DICTIONARY:
      putchar('[');
      print_type(type->key_type);
      putchar(':');
      print_type(type->value_type);
      putchar(']');
      break;
    case T_IDENTIFIER:
      printf("%s", type->identifier);
      break;
    case T_OPTIONAL:
      print_type(type->item_type);
      putchar('?');
  }
}

void log_indent(char* string, int level) {
  indent(level);
  printf("%s\n", string);
}

void indent(int level) {
  for(int i = 0; i < level; i++) {
    putchar(' ');
    putchar(' ');
  }
}
