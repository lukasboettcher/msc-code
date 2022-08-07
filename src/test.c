void MAYALIAS(void *p, void *q);

int main()
{
	int a, b, *c, *d;
	c = &a;
	d = &a;
	MAYALIAS(c, d);
}