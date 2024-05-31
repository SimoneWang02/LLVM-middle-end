#include <stdio.h>

// Monodimensionale e poi testare con N come argomento

#define N 3

void foo(int b[N][N], int c[N][N]) {
    int a[N][N];
    int d[N][N];

    int i, j;

    for (i = 0; i < N; i++)
        for (j = 0; j < N; j++)
            a[i][j] = 1 / b[i][j] * c[i][j];

    for (i = 0; i < N; i++)
        for (j = 0; j < N; j++)
            d[i][j] = a[i][j] * c[i][j];
}

int main() {
    int b[N][N] = { {1, 1, 1}, {1, 1, 1}, {1, 1, 1} };
    int c[N][N] = { {1, 1, 1}, {1, 1, 1}, {1, 1, 1} };

    foo(b, c);

    return 0;
}

/*--- Risultato atteso ---

for (i = 0; i < N; i++)
    for (j = 0; j < N; j++) {
        a[i][j] = 1 / b[i][j] * c[i][j];
        d[i][j] = a[i][j] * c[i][j];
    }

----------------------- */
