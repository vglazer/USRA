/* 
   generate random graphs of several types and output them as '-1' terminated 
   adjacency lists (only the upper portion of the adjacency list is output); 
   given an existing adjacency list in the above format, take its complement, 
   induce a subgraph on a subset of its vertices, their complement, common 
   neighbourhood and non-neighbourhood; convert incidence lists and their duals
   to adjacency lists

   the input parameters are:

   graph_type | one of five graph types, see below
   v          | number of vertices (adjacency lists) or symbols (incidence lists)
   num_sets   | number of sets (incidence lists only, negative for dual)
   density    | graph density (random graphs only)
   seed       | random seed, a positive integer (random graphs only)
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
#include <stdarg.h>
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

/* print an error message to stderr and exit */
static void die(const char *format, ...) {
    va_list args;

    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    fprintf(stderr, "\n");
    exit(EXIT_FAILURE);
}

/* allocate memory, exiting if none is available */
static void *xmalloc(size_t size) {
    void *p = malloc(size);

    if (p == NULL && size > 0) die("out of memory");
    return p;
}

static void *xcalloc(size_t count, size_t size) {
    void *p = calloc(count, size);

    if (p == NULL && count > 0 && size > 0) die("out of memory");
    return p;
}

/* read an integer, exiting on end of input or a non-integer */
static int read_int(void) {
    int x;

    if (scanf("%d", &x) != 1) 
        die("unexpected end of input or non-integer input");
    return x;
}

/* read a vertex in the range [0, v), or the -1 terminator if allow_end is set */
static int read_vertex(int v, int allow_end) {
    int x = read_int();

    if (allow_end && x == -1) return x;
    if (x < 0 || x >= v) die("vertex %d is out of range [0, %d)", x, v);
    return x;
}

/* main program */
int main(void) {
    int v, e, graph_type, density, num_sets, compl, num_fixed, num_rest, 
        fixed_type, sign, vert, temp, i, j, k, l, m, *curr_set;
    long seed;
    char **adj = NULL;

    /* input parameters */
    if (scanf("%d%d%d%d%ld%d%d%d", &graph_type, &v, &num_sets, &density, 
              &seed, &num_fixed, &fixed_type, &compl) != 8)
        die("expected 8 integer parameters: graph_type v num_sets density "
            "seed num_fixed fixed_type compl");

    /* echo parameters */
    printf("%d %d %d %d %ld  %d %d  %d\n", graph_type, v, num_sets, density, 
           seed, num_fixed, fixed_type, compl);

    /* validate parameters */
    if (graph_type < ADJ_LIST || graph_type > RAND_GEO)
        die("%d is not a valid graph type", graph_type);
    if (v < 0) die("number of vertices must be non-negative, got %d", v);
    if (graph_type == RAND_EXP || graph_type == RAND_POW || 
        graph_type == RAND_GEO) {
        if (density < 0 || density > 1000)
            die("density must be between 0 and 1000, got %d", density);
        /* a zero seed makes RAND return 0 forever */
        if (seed <= 0) die("seed must be a positive integer, got %ld", seed);
    } else if (graph_type == INC_LIST && density < 0) {
        die("density (intersection size) must be non-negative, got %d", 
            density);
    }
    if (num_fixed < 0) 
        die("number of fixed vertices must be non-negative, got %d", num_fixed);
    if (num_fixed > 0 && fixed_type != 1 && fixed_type != -1 && 
        fixed_type != 2 && fixed_type != -2 && fixed_type != 3)
        die("%d is not a valid fixed type", fixed_type);
    if (compl != 0 && compl != 1) 
        die("complementation flag must be 0 or 1, got %d", compl);

    /* allocate memory */
    if (graph_type != INC_LIST || num_sets >= 0) {
        adj = xmalloc(v * sizeof(char *));
        for (i = 0; i < v; i++) adj[i] = xcalloc(v, 1);
    }

    /* form adjacency matrix */
    if (graph_type == ADJ_LIST) { /* adjacency list */
        for (i = 0; i < v; i++) 
            for (;;) {
                vert = read_vertex(v, 1);
                if (vert == -1) break;
                adj[i][vert] = adj[vert][i] = 1;
            }      

    } else if (graph_type == INC_LIST) { /* incidence list */
        char **inc;

        /* allocate memory */
        sign = num_sets; if (num_sets < 0) num_sets = -num_sets;
        inc = xmalloc(num_sets * sizeof(char *));
        for (i = 0; i < num_sets; i++) inc[i] = xcalloc(v, 1);
        
        /* form incidence matrix */
        for (i = 0; i < num_sets; i++) 
            for (;;) {
                vert = read_vertex(v, 1); if (vert == -1) break; 
                inc[i][vert] = 1;
            }      
        
        /* form adjacency matrix */
        if (sign > 0) { /* primal */
            /* allocate memory */
            curr_set = xmalloc(num_sets * sizeof(int));

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
            adj = xmalloc(num_sets * sizeof(char *));
            for (i = 0; i < num_sets; i++) adj[i] = xcalloc(num_sets, 1);
            curr_set = xmalloc(v * sizeof(int));
            
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
        rand_perm = xmalloc(v * sizeof(int));
        
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
        x_coords = xmalloc(v * sizeof(int));
        y_coords = xmalloc(v * sizeof(int));

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

    } else { /* error; unreachable, since graph_type was validated above */
        die("%d is not a valid graph type", graph_type);
    }

    /* process graph, if desired */
    if (num_fixed > 0) {
        int *fixed_verts, *rest_verts, *sub_verts;
        char *fixed_charac;

        if (num_fixed > v) 
            die("%d fixed vertices requested, but the graph has only %d "
                "vertices", num_fixed, v);

        /* allocate memory */
        fixed_verts = xmalloc(num_fixed * sizeof(int));
        rest_verts = xmalloc((num_rest = v - num_fixed) * sizeof(int));
        fixed_charac = xcalloc(v, 1); 

        /* input fixed vertices */
        for (i = 0; i < num_fixed; i++) { 
            vert = read_vertex(v, 0);
            if (fixed_charac[vert]) die("fixed vertex %d is listed twice", vert);
            fixed_verts[i] = vert; fixed_charac[vert] = 1;
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
            curr_set = xmalloc(v * sizeof(int));
            box_charac = xcalloc(v, 1);

            /* store vertices adjacent to the first fixed vertex */
            vert = fixed_verts[0]; if (fixed_type > 0) l = 0; else l = 1;
            for (i = k = 0; i < v; i++) 
                if (!fixed_charac[i] && adj[vert][i] != l) curr_set[k++] = i;

            /* form neighbour list */
            for (i = 1; i < num_fixed; i++) 
                for (j = 0; j < k; j++) 
                    if (adj[fixed_verts[i]][curr_set[j]] == l)
                        curr_set[j--] = curr_set[--k];
            
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
        } else { /* unreachable, since fixed_type was validated above */
            die("%d is not a valid fixed type", fixed_type);
        }

        /* output subgraph vertices */
        printf("\n%d\n", temp);
        for (i = 0; i < temp; i++) printf(" %d", sub_verts[i]);
        printf("\n");
        printf("\n");

        /* form new adjacency matrix */
        if (fixed_type != 3) {
            char **sub_adj;

            /* allocate memory */
            sub_adj = xmalloc(temp * sizeof(char *));
            for (i = 0; i < temp; i++) sub_adj[i] = xcalloc(temp, 1);
        
            /* fill in adjacencies */
            for (i = 0; i < temp; i++) {
                k = sub_verts[i];
                for (j = i + 1; j < temp; j++) {
                    l = sub_verts[j];
                    if (adj[k][l]) sub_adj[i][j] = sub_adj[j][i] = 1;
                }
            }

            /* deallocate memory */
            for (i = 0; i < v; i++) free(adj[i]);
            free(adj);
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
    curr_set = xcalloc(v, sizeof(int));
    for (i = 0; i < v; i++) {
        for (j = temp = 0; j < v; j++)
            if (j != i && adj[i][j] != compl) temp++;
        curr_set[temp]++;
    }
    for (i = j = 0; i < v; i++) {
        if ((temp = curr_set[i]) > 0) { j++; printf("%-4d: %-4d ", i, temp); }
        if (j % VALS_PER_LINE == 0) { j++; printf("\n"); }
    }
    printf("\n");

    /* deallocate memory */ 
    for (i = 0; i < v; i++) free(adj[i]);
    free(adj); free(curr_set);
    
    exit(EXIT_SUCCESS);
}
