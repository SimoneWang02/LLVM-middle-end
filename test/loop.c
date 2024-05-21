#include <stdio.h>

void foo(int c, int z) {
  int a = 9, h, m = 0, n = 0, q, r = 0, y = 0;

LOOP:
  z = z + 1; // no
  y = c + 3; // yes
  q = c + 7; // yes
  if (z < 5) {
    a = a + 2; // no
    h = c + 3; // no
  } else {
    a = a - 1; // no
    h = c + 4; // no
    if (z >= 10) {
      goto EXIT;
    }
  }
  m = y + 7; // yes
  n = h + 2; // no
  y = c + 11; // yes, BUT it shouldn't be moved (Solution -> It has no uses so it should be removed)
  r = q + 5; // yes
  goto LOOP;
EXIT:
  printf("%d, %d, %d, %d, %d, %d, %d, %d\n", a, h, m, n, q, r, y, z);
}

int main() {
  foo(0, 4);
  foo(0, 12);
  return 0;
}