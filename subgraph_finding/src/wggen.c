/* 
   generate weighted exponential random graphs and output them as '-1' 
   terminated adjacency lists (only the upper portion of the adjacency list
   is output); the weights are encoded as follows: if the ith row of the 
   adjacency list contains entry x, then {i, (x % v)} is an edge with weight 
   (x / v) + 1 

   weights are stored as chars, both here and in wsub_search, so no weight
   may exceed CHAR_MAX
*/

/* header files */
#include <limits.h>
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
        fprintf(stderr, "usage: %s [ number of vertices ] [ density ] [ seed ] \n", 
                argv[0]);
        exit(EXIT_FAILURE);
    } else { v = atoi(argv[1]); d = atoi(argv[2]); seed = atol(argv[3]); }

    /* validate arguments; a zero seed makes RAND return 0 forever, so the
       search for k != j below would never terminate */
    if (v < 1 || d < 0 || seed <= 0) {
        fprintf(stderr, "%s: need v >= 1, density >= 0 and seed >= 1, "
                "got %d %d %ld\n", argv[0], v, d, seed);
        exit(EXIT_FAILURE);
    }

    /* compute the total weight in floating point, since v * (v - 1) * d
       overflows an int for large graphs */
    if ((double) v * (v - 1) * d / 200 > INT_MAX) {
        fprintf(stderr, "%s: total weight v * (v - 1) * density / 200 "
                "exceeds %d\n", argv[0], INT_MAX);
        exit(EXIT_FAILURE);
    }

    /* allocate memory */
    adj = malloc(v * sizeof(char *));
    for (i = 0; i < v; i++) adj[i] = calloc(v, 1);

    /* generate random graph */
    e = (int) ((double) v * (v - 1) * d / 200);
    for (i = 0; i < e; i++) { 
        j = RAND(v); for (;;) { k = RAND(v); if (k != j) break; }
        if (adj[j][k] == CHAR_MAX) {
            fprintf(stderr, "%s: edge weight exceeds %d; lower the density\n",
                    argv[0], CHAR_MAX);
            exit(EXIT_FAILURE);
        }
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
    for (i = 0; i < v; i++) free(adj[i]);
    free(adj);
    exit(EXIT_SUCCESS);
}
