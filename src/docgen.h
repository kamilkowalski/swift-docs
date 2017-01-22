#include <stdlib.h>

typedef enum {N_CLASS, N_CONSTANT, N_FUNCTION, N_VARIABLE} node_t;

typedef struct Node Node;

struct Node {
  node_t type;
  char* name;
  Node* next;
  Node* first_child;
};

Node* makeNode(node_t node_type, char* node_name);
void appendNode(Node* parent, Node* child);
