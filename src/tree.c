#include "tree.h"
#include <string.h>
#include <stdarg.h>

Node* make_node(node_t node_type, char* node_name, void* meta) {
  Node* node = (Node*) malloc(sizeof(Node));
  node->name = (char*) malloc(strlen(node_name) + 1);
  strcpy(node->name, node_name);

  node->meta = meta;
  node->type = node_type;
  node->next = 0;
  node->first_child = 0;
  node->parent = 0;

  return node;
}

void append_node(Node* parent, Node* child) {
  child->next = 0;
  child->parent = parent;

  if(parent->first_child) {
    Node* current = parent->first_child;

    while(current->next) {
      current = current->next;
    }

    current->next = child;
  } else {
    parent->first_child = child;
  }
}

Pattern* make_pattern(char* name) {
  Pattern* p = (Pattern*) malloc(sizeof(Pattern));
  p->type = 0;
  p->name = (char*) malloc(strlen(name) + 1);
  strcpy(p->name, name);
  return p;
}

Pattern* make_full_pattern(char* name, Type* type) {
  Pattern* p = make_pattern(name);
  p->type = type;
  return p;
}

Type* make_type(type_t category) {
  Type* t = (Type*) malloc(sizeof(Type));
  t->category = category;
  return t;
}

Type* make_identifier_type(char* identifier) {
  Type* t = make_type(T_IDENTIFIER);
  t->identifier = (char*) malloc(strlen(identifier) + 1);
  strcpy(t->identifier, identifier);
  return t;
}

Type* make_array_type(Type* item_type) {
  Type* t = make_type(T_ARRAY);
  t->item_type = item_type;
  return t;
}

Type* make_optional_type(Type* item_type) {
  return make_array_type(item_type);
}

Type* make_dictionary_type(Type* key_type, Type* value_type) {
  Type* t = make_type(T_DICTIONARY);
  t->key_type = key_type;
  t->value_type = value_type;
  return t;
}
