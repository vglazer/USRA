/* 
   generate random graphs of several types and output them as '-1' terminated 
   adjacency lists (only the upper portion of the adjacency list is output); 
   given an existing adjacency list in the above format, take its complement, 
   induce a subgraph on a subset of its vertices, their complement, common 
   neighbourhood and non-neighbourhood; convert incidence lists and their duals
   to adjacency lists

   the input parameters are:

   graph_type | one of five graph types, see below
   v          | number vertices (adjacency lists) or symbols (incidence lists) 
   num_sets   | number of sets (incidence lists only, negative for dual)
   density    | graph density (random graphs only)
   seed       | random seed, a non-negative integer
   num_fixed  | number of fixed vertices, if any
   fixed_type | one of five fixed types, see below
   compl      | complementation flag

   graph_type is interpreted as follows:

       0      | input a pre-existing adjacency list
       1      | input a pre-existing incidence list 
       2      | generate an exponential random graph
       3      | generate a power random graph
       4      | generate a geometric random graph

   fixed_type is interpreted as follows:

       1      | induce subgraph on Fixed
      -1      | induce subgraph on V \ Fixed 
       2      | induce subgraph on the common neighbourhood of Fixed
      -2      | induce subgraph on the common non-neighbourhood of Fixed
       3      | switch graph with respect to Fixed

   compl is interpreted as follows:

       0      | output the adjacency list
       1      | output the complement of the adjacency list
*/

/* header files */
#include <stdio.h> 
#include <stdlib.h>

/* a factor used in random graph generation */
#define SCALE 10000

/* graph types */
#define ADJ_LIST 0
#define INC_LIST 1
#define RAND_EXP 2
#define RAND_POW 3
#define RAND_GEO 4

/* formatting parameters */
#define VALS_PER_LINE 7

/* generate a pseudorandom number between 0 and bound - 1 */
#define RAND(bound) (((seed = (seed * 65539L) & 017777777777L) / 7) % (bound))

/* main program */
int main(void) {
    int v, e, graph_type, density, num_sets, compl, num_fixed, num_rest, 
        fixed_type, sign, vert, temp, i, j, k, l, m, *curr_set;
    long seed;
    char **adj = NULL;

    /* input parameters */
    scanf("%d%d%d%d%ld%d%d%d", &graph_type, &v, &num_sets, &density, &seed, 
          &num_fixed, &fixed_type, &compl);

    /* echo parameters */
    printf("%d %d %d %d %ld  %d %d  %d\n", graph_type, v, num_sets, density, 
           seed, num_fixed, fixed_type, compl);

    /* allocate memory */
    if (graph_type != INC_LIST || num_sets >= 0) {
        adj = malloc(v * sizeof(char *));
        for (i = 0; i < v; i++) adj[i] = calloc(v, 1);
    }

    /* form adjacency matrix */
    if (graph_type == ADJ_LIST) { /* adjacency list */
        for (i = 0; i < v; i++) 
            for (;;) {
                scanf("%d", &vert);
                if (vert == -1) break;
                adj[i][vert] = adj[vert][i] = 1;
            }      

    } else if (graph_type == INC_LIST) { /* incidence list */
        char **inc;

        /* allocate memory */
        sign = num_sets; if (num_sets < 0) num_sets = -num_sets;
        inc = malloc(num_sets * sizeof(char *));
        for (i = 0; i < num_sets; i++) inc[i] = calloc(v, 1);
        
        /* form incidence matrix */
        for (i = 0; i < num_sets; i++) 
            for (;;) {
                scanf("%d", &vert); if (vert == -1) break; inc[i][vert] = 1;
            }      
        
        /* form adjacency matrix */
        if (sign > 0) { /* primal */
            /* allocate memory */
            curr_set = malloc(num_sets * sizeof(int));

            /* form adjacency matrix */
            for (i = 0; i < v; i++) {
                for (j = k = 0; j < num_sets; j++) 
                    if (inc[j][i]) curr_set[k++] = j;

                for (j = i + 1; j < v; j++) {
                    for (l = m = 0; l < k; l++) 
                        if (inc[curr_set[l]][j]) m++;
                    if (m == density) adj[i][j] = adj[j][i] = 1;
                }
            }

        } else { /* dual */
            /* allocate memory */
            adj = malloc(num_sets * sizeof(char *));
            for (i = 0; i < num_sets; i++) adj[i] = calloc(num_sets, 1);
            curr_set = malloc(v * sizeof(int));
            
            /* form adjacency matrix */
            for (i = 0; i < num_sets; i++) {
                for (j = k = 0; j < v; j++) 
                    if (inc[i][j]) curr_set[k++] = j;
                
                for (j = i + 1; j < num_sets; j++) {
                    for (l = m = 0; l < k; l++) 
                        if (inc[j][curr_set[l]]) m++;
                    if (m == density) adj[i][j] = adj[j][i] = 1;
                }
            }
            
            /* set new values */
            v = num_sets;
        }

        /* deallocate memory */
        for (i = 0; i < num_sets; i++) free(inc[i]);
        free(inc); free(curr_set);
            
    } else if (graph_type == RAND_EXP) { /* exponential random graph */
        m = density * SCALE / 1000;
        for (i = 0; i < v; i++) 
            for (j = i + 1; j < v; j++) 
                if (RAND(SCALE) < m) adj[i][j] = adj[j][i] = 1;
            
    } else if (graph_type == RAND_POW) { /* scale-free random graph */
        int *rand_perm;

        /* allocate memory */
        rand_perm = malloc(v * sizeof(int));
        
        l = density * (v - 1) / (2000 - density);
        for (i = 0; i < v - l; i++) {
            for (j = 0; j < v - i; j++) rand_perm[j] = j;
            k = v - i - l - 1;
            for (j = l + k; j > k; j--) {
                temp = RAND(j); m = rand_perm[temp] + i + 1;
                rand_perm[temp] = rand_perm[j - 1]; adj[i][m] = adj[m][i] = 1;
            }
        }

        /* deallocate memory */
        free(rand_perm);

    } else if (graph_type == RAND_GEO) { /* geometric random graph */
        int *x_coords, *y_coords;

        /* allocate memory */
        x_coords = malloc(v * sizeof(int));
        y_coords = malloc(v * sizeof(int));

        for (i = 0; i < v; i++) {
            x_coords[i] = RAND(SCALE); y_coords[i] = RAND(SCALE);
        }

        m = SCALE * SCALE / 3140 * density;
        for (i = 0; i < v; i++) 
            for (j = i + 1; j < v; j++) {
                k = x_coords[i] - x_coords[j]; l = y_coords[i] - y_coords[j];
                if (k * k + l * l < m) adj[i][j] = adj[j][i] = 1;
            }

        /* deallocate memory */
        free(x_coords); free(y_coords);

    } else { /* error */
        printf("%d is not a valid graph type\n", graph_type);
        exit(EXIT_FAILURE);
    }

    /* process graph, if desired */
    if (num_fixed > 0) {
        int *fixed_verts, *rest_verts, *sub_verts;
        char *fixed_charac;

        /* allocate memory */
        fixed_verts = malloc(num_fixed * sizeof(int));
        rest_verts = malloc((num_rest = v - num_fixed) * sizeof(int));
        fixed_charac = calloc(v, 1); 

        /* input fixed vertices */
        for (i = 0; i < num_fixed; i++) { 
            scanf("%d", &vert); fixed_verts[i] = vert; fixed_charac[vert] = 1;
        }
        for (i = k = 0; i < v; i++) 
            if (!fixed_charac[i]) rest_verts[k++] = i;
        
        /* induce subgraph on Fixed */
        if (fixed_type == 1) { 
            temp = num_fixed; sub_verts = fixed_verts;

        /* induce subgraph on V \ Fixed */
        } else if (fixed_type == -1) {
            temp = num_rest; sub_verts = rest_verts;

        /* induce subgraph on common neighbourhood or 
           common non-neighbourhood of Fixed, respectively */
        } else if (fixed_type == 2 || fixed_type == -2) { 
            char *box_charac;

            /* allocate memory */
            curr_set = malloc(v * sizeof(int));
            box_charac = calloc(v, 1);

            /* store vertices adjacent to the first fixed vertex */
            vert = fixed_verts[0]; if (fixed_type > 0) l = 0; else l = 1;
            for (i = k = 0; i < v; i++) 
                if (!fixed_charac[i] && adj[vert][i] != l) curr_set[k++] = i;

            /* form neighbour list */
            for (i = 1; i < num_fixed; i++) 
                for (j = 0; j < k; j++) 
                    if (adj[fixed_verts[i]][curr_set[j]] == l)
                        curr_set[j--] = curr_set[--k];;
            
            /* Sort the vertices in ascending order */
            for (i = 0; i < k; i++) box_charac[curr_set[i]] = 1;
            for (i = j = 0; i < v; i++) if (box_charac[i]) curr_set[j++] = i;

            /* deallocate memory */
            free(box_charac);
            temp = k; sub_verts = curr_set;

        /* switch graph with respect to Fixed */
        } else if (fixed_type == 3) {            
            /* for fixed vertices, switch rest, and vice versa */
            for (i = 0; i < num_fixed; i++) {
                vert = fixed_verts[i];
                for (j = 0; j < num_rest; j++) {
                    temp = rest_verts[j];
                    adj[vert][temp] = 1 - adj[vert][temp];
                }
            }
            for (i = 0; i < num_rest; i++) {
                vert = rest_verts[i];
                for (j = 0; j < num_fixed; j++) {
                    temp = fixed_verts[j];
                    adj[vert][temp] = 1 - adj[vert][temp];
                }
            }

            temp = num_fixed; sub_verts = fixed_verts;
        
        /* error */
        } else {
            printf("%d is not a valid fixed type\n", fixed_type);
            exit(EXIT_FAILURE);
        }

        /* output subgraph vertices */
        printf("\n%d\n", temp);
        for (i = 0; i < temp; i++) printf(" %d", sub_verts[i]); printf("\n");
        printf("\n");

        /* form new adjacency matrix */
        if (fixed_type != 3) {
            char **sub_adj;

            /* allocate memory */
            sub_adj = malloc(temp * sizeof(char *));
            for (i = 0; i < temp; i++) sub_adj[i] = calloc(temp, 1);
        
            /* fill in adjacencies */
            for (i = 0; i < temp; i++) {
                k = sub_verts[i];
                for (j = i + 1; j < temp; j++) {
                    l = sub_verts[j];
                    if (adj[k][l]) sub_adj[i][j] = sub_adj[j][i] = 1;
                }
            }

            /* deallocate memory */
            for (i = 0; i < v; i++) free(adj[i]); free(adj);        
            adj = sub_adj; v = temp;
        }
    
        /* deallocate memory */
        free(fixed_verts); free(rest_verts); free(fixed_charac);  
        if (fixed_type == 2 || fixed_type == -2) free(sub_verts);
    }

    /* output adjacency list */
    for (i = e = 0; i < v; i++) {
        for (j = i + 1; j < v; j++) 
            if (adj[i][j] != compl) { printf(" %d", j); e++; }
        printf("-1\n");
    }
    printf("\nV = %d, E = %d\n", v, e);

    /* compute degrees and output degree spectrum */
    curr_set = calloc(v, sizeof(int));
    for (i = 0; i < v; i++) {
        for (j = temp = 0; j < v; j++) if (adj[i][j]) temp++; 
        curr_set[temp]++;
    }
    for (i = j = 0; i < v; i++) {
        if ((temp = curr_set[i]) > 0) { j++; printf("%-4d: %-4d ", i, temp); }
        if (j % VALS_PER_LINE == 0) { j++; printf("\n"); }
    }
    printf("\n");

    /* deallocate memory */ 
    for (i = 0; i < v; i++) free(adj[i]); free(adj); free(curr_set);
    
    exit(EXIT_SUCCESS);
}
