#include "html_formatter.h"
#include <stdio.h>
#include <string.h>

char* header();
void write_content(Node* node, FILE* out);
void write_node(Node* node, FILE* out);
void write_class_info(Node* class, FILE* out);
void write_constant_info(Node* constant, FILE* out);
void write_function_info(Node* function, FILE* out);
void write_root_info(Node* root, FILE* out);
void write_variable_info(Node* variable, FILE* out);
void write_class_child_type(Node* class, node_t type, FILE* out);
void write_node_type(Node* typable, FILE* out);
void write_type(Type* type, FILE* out);
char* footer();

char* readfile(char* filename);

void html_format(Node* root_node, char* output_file) {
  FILE* output = fopen(output_file, "w");
  fputs(header(), output);
  write_content(root_node, output);
  fputs(footer(), output);
  fclose(output);
}

char* header() {
  return readfile("src/templates/_header.html");
}

char* footer() {
  return readfile("src/templates/_footer.html");
}

void write_content(Node* root_node, FILE* out) {
  fprintf(out, "<h1>Swift Docs</h1>\n");
  write_node(root_node, out);
}

void write_node(Node* node, FILE* out) {
  switch(node->type) {
    case N_CLASS:
      write_class_info(node, out);
      break;
    case N_CONSTANT:
      write_constant_info(node, out);
      break;
    case N_FUNCTION:
      write_function_info(node, out);
      break;
    case N_ROOT:
      write_root_info(node, out);
      break;
    case N_VARIABLE:
      write_variable_info(node, out);
      break;
  }
}

void write_class_info(Node* class, FILE* out) {
  fprintf(out, "<h3>Class <code>%s</code></h3>", class->name);

  fprintf(out, "<table class=\"table\">");

  fprintf(out, "<tr><td>");
  fprintf(out, "<h4>Constants</h4>");
  fprintf(out, "<ul>");
  write_class_child_type(class, N_CONSTANT, out);
  fprintf(out, "</ul>");
  fprintf(out, "</td></tr>");

  fprintf(out, "<tr><td>");
  fprintf(out, "<h4>Variables</h4>");
  fprintf(out, "<ul>");
  write_class_child_type(class, N_VARIABLE, out);
  fprintf(out, "</ul>");
  fprintf(out, "</td></tr>");

  fprintf(out, "<tr><td>");
  fprintf(out, "<h4>Functions</h4>");
  fprintf(out, "<ul>");
  write_class_child_type(class, N_FUNCTION, out);
  fprintf(out, "</ul>");
  fprintf(out, "</td></tr>");

  fprintf(out, "</table>");
}

void write_class_child_type(Node* class, node_t type, FILE* out) {
  if (class->first_child) {
    Node* current = class->first_child;

    while(current) {
      if (current->type == type) {
        fprintf(out, "<li>");
        switch(type) {
          case N_CONSTANT:
            write_constant_info(current, out);
            break;
          case N_VARIABLE:
            write_variable_info(current, out);
            break;
          case N_FUNCTION:
            write_function_info(current, out);
            break;
          default:
            break;
        }
        fprintf(out, "</li>");
      }

      current = current->next;
    }
  }
}

void write_constant_info(Node* constant, FILE* out) {
  fprintf(out, "Constant <code>%s</code>", constant->name);
  write_node_type(constant, out);
}

void write_function_info(Node* function, FILE* out) {
  fprintf(out, "Function <code>%s</code>", function->name);
}

void write_root_info(Node* root, FILE* out) {
  fprintf(out, "<h2>%s</h2>\n", root->name);

  if (root->first_child) {
    Node* current = root->first_child;

    while(current) {
      write_node(current, out);
      current = current->next;
    }
  }
}

void write_variable_info(Node* variable, FILE* out) {
  fprintf(out, "Variable <code>%s</code>", variable->name);
  write_node_type(variable, out);
}

void write_node_type(Node* typable, FILE* out) {
  if (typable->meta) {
    fprintf(out, " : ");
    write_type((Type*) typable->meta, out);
  }
}

void write_type(Type* type, FILE* out) {
  switch(type->category) {
    case T_ARRAY:
      fprintf(out, "[");
      write_type(type->item_type, out);
      fprintf(out, "]");
      break;
    case T_DICTIONARY:
      fprintf(out, "[");
      write_type(type->key_type, out);
      fprintf(out, ":");
      write_type(type->value_type, out);
      fprintf(out, "]");
      break;
    case T_IDENTIFIER:
      fprintf(out, "<code>%s</code>", type->identifier);
      break;
    case T_OPTIONAL:
      write_type(type->item_type, out);
      fprintf(out, "?");
  }
}

char* readfile(char* filename) {
  FILE *f = fopen(filename, "rb");

  fseek(f, 0, SEEK_END);
  long fsize = ftell(f);
  fseek(f, 0, SEEK_SET);

  char* contents = malloc(fsize + 1);
  fread(contents, fsize, 1, f);
  fclose(f);

  contents[fsize] = 0;
  return contents;
}
