#include <stdlib.h>
int main(int argc, char const *argv[])
{
    int *e, *h, **c, **g, ***b, ***a, ***f, ****d;
    a = b;
    b = &c;
    d = &a;
    e = malloc(1);
    *c = e;
    f = *d;
    g = *f;
    h = *g;
}
