#include <stdlib.h>

struct node
{
    int data;
    struct node *next;
};

int main()
{
    struct node *head0 = (struct node *)malloc(sizeof(struct node));
    struct node *next1 = (struct node *)malloc(sizeof(struct node));
    struct node *next2 = (struct node *)malloc(sizeof(struct node));
    struct node *next3 = (struct node *)malloc(sizeof(struct node));

    head0->next = next1;
    next1->next = next2;
    next2->next = next3;
}
