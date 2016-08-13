/* 
   generate weighted exponential random graphs and output them as '-1' 
   terminated adjacency lists (only the upper portion of the adjacency list
   is output); the weights are encoded as follows: if the ith row of the 
   adjacency list contains entry x, then {i, (x % v)} is an edge with weight 
   (x / v) + 1 
*/

/* header files */
#include <stdio.h>
#include <stdlib.h>

/* generate pseudorandom number between 0 and bound - 1 */
#define RAND(bound) (((seed = (seed * 65539L) & 017777777777L) / 7) % (bound))

/* main program */
int main(int argc, char *argv[]) {
    int v, d, e, i, j, k;
    char **adj;
    long seed;

    /* parse command line arguments */
    if (argc != 4) { 
        printf("usage: %s [ number of vertices ] [ density ] [ seed ] \n", 
               argv[0]);
        exit(EXIT_FAILURE);
    } else { v = atoi(argv[1]); d = atoi(argv[2]); seed = atoi(argv[3]); }

    /* allocate memory */
    adj = malloc(v * sizeof(char *));
    for (i = 0; i < v; i++) adj[i] = calloc(v, 1);

    /* generate random graph */
    e = v * (v - 1) * d / 200;
    for (i = 0; i < e; i++) { 
        j = RAND(v); for (;;) { k = RAND(v); if (k != j) break; }
        adj[j][k]++; adj[k][j]++;
    }

    /* output adjacency list */
    for (i = 0; i < v; i++) {
        for (j = i + 1; j < v; j++) 
            if ((k = adj[i][j])) printf("%d ", j + (k - 1) * v);
        printf("-1\n");
    }
    printf("\nV = %d, E = %d\n", v, e);
       
    /* deallocate memory and exit */
    for (i = 0; i < v; i++) free(adj[i]); free(adj); exit(EXIT_SUCCESS);
}
