#include <stdlib.h>
int g = 1;

void procedure(int *a)
{
  if (*a > 0)
  {
    if (*a == 5)
    {
      free(a);
    }
    
    *a = *a - g;
    procedure(a);
  }
}

int main()
{
  int *x = malloc(sizeof(int)*1);
  x[0] = 10;

  procedure(x);

  // int *a, b, c, *d, **e, *f;
  // a = &b;
  // d = &c;
  // d = a;
  // e = &a;
  // *e = d;
  // f = *e;

  // int *x, *y, v1, v2;
  // x = &v1;
  // x = &v2;
  // y = &v1;

  // int a[10], *x, *y;
  // x = &a[1];
  // y = &a[2];
  // int *a[2], x, y;
  // a[0] = &x;
  // a[1] = &y;
}
