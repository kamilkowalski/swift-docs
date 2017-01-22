#include "docgen.h"
#include <string.h>

Node* make_node(node_t node_type, char* node_name) {
  Node* node = (Node*) malloc(sizeof(Node));
  node->name = (char*) malloc(strlen(node_name) + 1);
  strcpy(node->name, node_name);

  node->type = node_type;
  node->next = 0;
  node->first_child = 0;

  return node;
}

void append_node(Node* parent, Node* child) {
  child->next = 0;

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
