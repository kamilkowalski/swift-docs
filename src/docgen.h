#include <stdlib.h>

typedef enum {N_CLASS, N_CONSTANT, N_FUNCTION, N_ROOT, N_VARIABLE} node_t;

typedef struct Node Node;

struct Node {
  node_t type;
  char* name;
  Node* next;
  Node* first_child;
};

Node* make_node(node_t node_type, char* node_name);
void append_node(Node* parent, Node* child);
