typedef struct node_s
{
  int item;
  struct node_s *next;
} node;

typedef struct 
{
  node *head;
  node *tail;
} queue;
