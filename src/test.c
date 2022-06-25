// #include "aliascheck.h"
// #include "stdlib.h"

void MAYALIAS(void *p, void *q)
{
	printf("\n");
}

// void MUSTALIAS(void *p, void *q)
// {
// 	printf("\n");
// }

// void NOALIAS(void *p, void *q)
// {
// 	printf("\n");
// }

struct MyStruct {
	int * f1;
	struct MyStruct * next;
};

int main() {
	struct MyStruct * p = (struct MyStruct *) malloc (sizeof(struct MyStruct));
	int num = 10;
	while (num) {
		p->next = (struct MyStruct *) malloc (sizeof(struct MyStruct));
		p->next->f1 = (int *) malloc (sizeof(int));
		p = p->next;
	}
	struct MyStruct *q = p;
	MAYALIAS(q->next, p->next->next);
	MAYALIAS(q->f1, p->next->f1);
	return 0;
}
