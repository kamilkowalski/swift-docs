#ifndef _TREEH_
#define _TREEH_
#include <stdlib.h>

typedef enum {N_CLASS, N_CONSTANT, N_FUNCTION, N_ROOT, N_VARIABLE} node_t;
typedef enum {T_ARRAY, T_DICTIONARY, T_IDENTIFIER, T_OPTIONAL} type_t;

typedef struct Node Node;
typedef struct Pattern Pattern;
typedef struct Type Type;

struct Node {
  node_t type;
  char* name;
  void* meta; // Type or Function
  Node* next;
  Node* first_child;
  Node* parent;
};

struct Pattern {
  char* name;
  Type* type;
};

struct Type {
  type_t category;
  char* identifier;
  Type* item_type;
  Type* key_type;
  Type* value_type;
};

Node* make_node(node_t node_type, char* node_name, void* meta);
void append_node(Node* parent, Node* child);

Pattern* make_full_pattern(char* name, Type* type);
Pattern* make_pattern(char* name);

Type* make_type(type_t category);
Type* make_identifier_type(char* identifier);
Type* make_array_type(Type* item_type);
Type* make_optional_type(Type* item_type);
Type* make_dictionary_type(Type* key_type, Type* value_type);

#endif
