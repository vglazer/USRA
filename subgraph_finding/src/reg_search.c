/* 
   use randomised restricted local search to find regular vertex-induced
   subgraphs with a prescribed valency in undirected, unweighted graphs

   the input parameters are:

   v         | number of graph vertices
   v_sub     | number of subgraph vertices 
   d_sub     | subgraph valency
   v_fix     | number of fixed vertices, if any
   num_exps  | number of experiments to perform
   num_moves | maximum allowed number of moves per experiment
   div_freq  | diversification frequency, in moves (how often to shake)
   div_dur   | diversification duration, in moves (how long to shake for)
   seed      | random seed, a non-negative integer
   show_sols | output format

   show_sols is interpreted as follows:

    0        | output the global objective function minimum attained for 
             | each experiment
    n, n > 0 | output the global minimum as above; if it is strictly less 
             | than n, output the subgraph vertices as well 
    n, n < 0 | output the global minimum as above; if it is strictly less
             | than |n|, output the subgraph vertices, their adjacencies 
             | and the vertex and edge counts as well

   the post-experimental output is:

     line 1  | number of successful experiments 
             | "box distribution" (the interval [1, num_moves] is partitioned
             | into NUM_BOXES subintervals of equal length, or "boxes"; every 
             | successful experiment then contributes 1 to the appropriate box
             | (e.g. if num_moves is 1000 and NUM_BOXES is 10, a successful 
             | experiment where the solution was found in 220 moves will 
             | contribute 1 to box 3)
     line 2  | average cost (in moves) of a successful experiment, counting 
             | successful experiments only (the "relative cost")
             | average cost (in moves) of a successful experiment, counting
             | all experiments (the "true cost")
             | global objective function minimum attained, averaged over all 
             | experiments (the "average conflict")
             | CPU time used (in seconds)
             | host machine
*/

/* header files */
#include <stdio.h> 
#include <stdlib.h>
#include <string.h>
#include <sys/time.h> 
#include <sys/resource.h> 

/* formatting parameters */
#define VALS_PER_LINE 25
#define NUM_BOXES 10
#define NAMELEN 16

/* generate pseudorandom number between 0 and bound - 1 */
#define RAND(bound) (((seed = (seed * 65539L) & 017777777777L) / 7) % (bound))

/* report host name and time taken */
int gethostname(char *name, int namelen);
void showtimings(FILE *fp) {
    struct rusage resources; char hostname[NAMELEN]; double time_taken;

    /* obtain host name from system */
    if (gethostname(hostname, NAMELEN) == -1) {
        perror("gethostname() failed"); exit(EXIT_FAILURE);
    }

    /* obtain resource usage from system */
    if (getrusage(RUSAGE_SELF, &resources) == -1) { 
        perror("getrusage() failed"); exit(EXIT_FAILURE); 
    }

    /* output timing and host information */
    time_taken = (double)resources.ru_utime.tv_usec / 1000000
        + (double)resources.ru_utime.tv_sec;
    fprintf(fp, "T> %.2f seconds H> %s\n", time_taken, hostname);
}

/* main program */
int main(void) {
    /* experimental parameters */
    int num_exps, num_mov, div_freq, div_dur, boxsize, show_sols;
    long seed;

    /* graph data */
    int v, v_sq, v_sub, v_rest, v_fix, d_sub, e, *degs, **adj_list;
    short **adj;

    /* bookkeeping data */
    int *boxes, *sub_degs, *sub_verts, *rest_verts, *vert_inds, *sub_opt,
        *rest_opt, *diffs, *u_list, *rand_perm;
    char *sub_ch, *opt_ch, *u_ch;
    int sub_vert, rest_vert, sub_row, rest_col, g_opt_val, opt_val, opt_mov,
        old_min_val, new_min_val, glob_vals, succ_mov, succ_exp, tot_mov, 
        u_cols, w_cols; 

    /* miscellaneous */
    int i, j, k, l, m, temp, obj_val, curr_val, curr_rest, vert, degree, index;

    /* input experiment parameters */
    scanf("%d%d%d%d%d%d%d%d%ld%d", &v, &v_sub, &d_sub, &v_fix, &num_exps,
          &num_mov, &div_freq, &div_dur, &seed, &show_sols);

    /* echo experimental parameters */
    printf("%d %d %d %d  %d %d %d %d %ld  %d\n", v, v_sub, d_sub, v_fix,
          num_exps, num_mov, div_freq, div_dur, seed, show_sols);
 
    /* reject invalid subgraphs */
    if (v_sub < 2 || v_sub <= v_fix || v_sub > v - 1) {
        printf("%d is not a valid subgraph size\n", v_sub);
        exit(EXIT_FAILURE);
    }

    /* reject invalid diversification frequencies */
    if (div_freq < 1) {
        printf("%d is not a valid diversification frequency\n", div_freq);
        exit(EXIT_FAILURE);
    }
    v_rest = v - v_sub; v_sub = v_sub - v_fix;
    v_sq = v * v;

    /* allocate memory for the graph */
    adj = malloc(v * sizeof(short *));
    for (i = 0; i < v; i++) {
        adj[i] = malloc(v * sizeof(short));
        for (j = 0; j < v; j++) adj[i][j] = -1;
    }
    adj_list = malloc(v * sizeof(int *)); degs = calloc(v, sizeof(int));

    /* allocate memory for bookkeeping */
    sub_degs = malloc(v * sizeof(int)); rand_perm = malloc(v * sizeof(int));
    sub_opt = malloc(v * sizeof(int)); rest_opt = malloc(v * sizeof(int));
    sub_verts = malloc(v_sub * sizeof(int)); 
    rest_verts = malloc(v_rest * sizeof(int));
    vert_inds = malloc(v * sizeof(int)); diffs = calloc(v, sizeof(int));
    sub_ch = calloc(v, 1); opt_ch = calloc(v, 1); u_ch = calloc(v, 1);
    u_list = malloc(v_rest * sizeof(int));
    boxes = calloc(NUM_BOXES, sizeof(int));

    /* fill in adjacency matrix */
    for (i = 0; i < v; i++) 
        for (;;) {
            scanf("%d", &vert); if (vert == -1) break;
            adj[i][vert] = adj[vert][i] = 0;
        }      

    /* count degrees and edges */
    for (i = e = 0; i < v; i++) {  
        for (j = k = 0; j < v; j++) if (adj[i][j] >= 0) k++; 
        degs[i] = k; e += k; 
    }   

    /* input fixed vertices, if there are any */
    for (i = 0; i < v_fix; i++) { scanf("%d", &vert); sub_ch[vert] = 1; }

    /* initialise permutations */
    for (i = j = 0; i < v; i++) if (!sub_ch[i]) rand_perm[j++] = i;

    /* begin experiments */
    tot_mov = succ_mov = succ_exp = glob_vals = obj_val = 0;
    boxsize = num_mov / NUM_BOXES + 1;
    for (i = 0; i < num_exps; i++) {
        /* generate new random subgrapgh */
        for (j = v - v_fix, k = 0; k < v_sub; k++) {
            index = RAND(j); vert = rand_perm[index];
            rand_perm[index] = rand_perm[--j]; rand_perm[j] = vert;
            sub_ch[vert] = 1; sub_verts[k] = vert; vert_inds[vert] = k; 
        }

        /* form adjacency list and compute sub degrees */
        for (j = 0; j < v; j++) {
            degree = degs[j]; adj_list[j] = malloc(degree * sizeof(int));
            for (k = l = m = 0; k < v; k++) 
                if (adj[j][k] >= 0 && sub_ch[k]) adj_list[j][l++] = k;
                else if (adj[j][k] >= 0) diffs[m++] = k;
            for (k = l; k < degree; k++) adj_list[j][k] = diffs[k - l];
            sub_degs[j] = l; u_ch[j] = 0;
        }

        /* convert adjacency matrix to index format */
        for (j = 0; j < v; j++) 
            for (k = 0; k < degs[j]; k++) adj[j][adj_list[j][k]] = k;

        /* initialise objective function value and sub degree differences */
        for (j = l = obj_val = 0; j < v; j++) 
            if (sub_ch[j]) {
                temp = diffs[j] = sub_degs[j] - d_sub;
                if (temp > 0) obj_val += temp; else obj_val -= temp;
            } else  { vert_inds[j] = l; rest_verts[l++] = j; }

        /* begin moves */       
        opt_val = g_opt_val = old_min_val = v_sq; opt_mov = 0;
    	for (j = 0; j < num_mov; j++) {
            /* select one of two types of moves */
            if (j % div_freq < div_dur || !opt_mov) { /* diversify */
                sub_vert = sub_verts[RAND(v_sub)];
                rest_vert = rest_verts[RAND(v_rest)];

            } else { /* take locally optimal move */
                index = RAND(opt_mov); 
                sub_vert = sub_opt[index]; rest_vert = rest_opt[index];
            }
            sub_row = vert_inds[sub_vert]; rest_col = vert_inds[rest_vert];

            /* set objective function value and update differences */
            if ((temp = diffs[sub_vert]) > 0) obj_val -= temp;
            else obj_val += temp;
            for (k = 0; k < sub_degs[sub_vert]; k++) {
                if (diffs[vert = adj_list[sub_vert][k]] > 0) obj_val--; 
                else obj_val++; diffs[vert]--;
            }
            for (k = 0; k < sub_degs[rest_vert]; k++) {
                if ((vert = adj_list[rest_vert][k]) == sub_vert) continue;
                if (diffs[vert] >= 0) obj_val++; else obj_val--; diffs[vert]++;
            }

            /* update sub degrees, select active rows and columns */
            for (k = 0; k < degs[sub_vert]; k++) {
                sub_degs[vert = adj_list[sub_vert][k]]--; u_ch[vert] = 1;
            }            
            for (k = 0; k < degs[rest_vert]; k++) {
                sub_degs[vert = adj_list[rest_vert][k]]++;
                u_ch[vert] = 1 - u_ch[vert];
            }

            /* compensate obj_val for rest_vert and compute difference */
            temp = diffs[rest_vert] = sub_degs[rest_vert] - d_sub;
            if (temp > 0) obj_val += temp; else obj_val -= temp; 

            /* update characteristic vector */
            sub_ch[sub_vert] = 0; sub_ch[rest_vert] = 1;

            /* update global minimum and store subgraph vertices, 
               if necessary */
            if ((new_min_val = obj_val) < g_opt_val) { 
                g_opt_val = obj_val; memcpy(opt_ch, sub_ch, v);
            }

            /* update vertex lists */
            sub_verts[sub_row] = rest_vert; vert_inds[rest_vert] = sub_row;
            rest_verts[rest_col] = sub_vert; vert_inds[sub_vert] = rest_col;

            /* update partitioning of adjacency list */
            for (k = 0; k < degs[sub_vert]; k++) {
                vert = adj_list[sub_vert][k];
                index = adj[vert][sub_vert]; temp = adj[vert][rest_vert];
                if (temp >= 0) {
                    adj_list[vert][index] = rest_vert;
                    adj_list[vert][temp] = sub_vert;
                    adj[vert][sub_vert] = temp; adj[vert][rest_vert] = index;
                } else if (index != (degree = sub_degs[vert])) {
                    adj_list[vert][index] = temp = adj_list[vert][degree];
                    adj_list[vert][degree] = sub_vert;
                    adj[vert][temp] = index; adj[vert][sub_vert] = degree;
                }
            }
            for (k = 0; k < degs[rest_vert]; k++) {
                vert = adj_list[rest_vert][k];
                index = adj[vert][sub_vert]; temp = adj[vert][rest_vert];
                if (index >= 0) continue;
                if (temp != (degree = sub_degs[vert] - 1)) {
                    adj_list[vert][temp] = index = adj_list[vert][degree];
                    adj_list[vert][degree] = rest_vert;
                    adj[vert][index] = temp; adj[vert][rest_vert] = degree;
                }
            }

            /* solution found, update statistics accordingly */
            if (!obj_val) {
                succ_exp++; succ_mov += j; 
                index = j / boxsize; boxes[index]++; break;
            }      

            /* extract a list of active columns */
            u_cols = u_ch[sub_vert] = 0; temp = index = v_rest - 1;
            for (k = 0; k < v_rest; k++) {
                if (k == rest_col) continue;
                if (u_ch[vert = rest_verts[k]]) {
                    u_list[u_cols++] = vert; u_ch[vert] = 0;
                } else u_list[--temp] = vert; 
            }
                
            if (new_min_val != old_min_val)
                for (k = 0; k < v_sub; k++) u_ch[sub_verts[k]] = 1;
                    
            /* obtain new list of optimal moves */
            opt_val = v_sq; curr_rest = rest_vert;
            opt_mov = degree = curr_val = u_ch[rest_vert] = 0;
            for (k = 0; k < v_sub; k++) {
                if ((sub_vert = sub_verts[k]) == curr_rest) continue;

                /* determine which columns are active, reset rows */
                if (u_ch[sub_vert]) { w_cols = index; u_ch[sub_vert] = 0; }
                else w_cols = u_cols;

                if ((temp = diffs[sub_vert]) > 0) degree = obj_val - temp;
                else degree = obj_val + temp;

                for (l = 0; l < sub_degs[sub_vert]; l++) 
                    if (diffs[adj_list[sub_vert][l]]-- > 0) degree--; 
                    else degree++;              

                for (l = 0; l < w_cols; l++) {
                    curr_val = degree; rest_vert = u_list[l];

                    temp = sub_degs[rest_vert] - d_sub;
                    for (m = 0; m < sub_degs[rest_vert]; m++) {
                        if ((vert = adj_list[rest_vert][m]) == sub_vert) 
                            temp--;
                        else if (diffs[vert] >= 0) curr_val++; else curr_val--;
                    }
                    if (temp > 0) curr_val += temp; else curr_val -= temp;
                    
                    /* store optimal move and update minima, if applicable */
                    if (curr_val <= opt_val) {
                        if (curr_val < opt_val) { 
                            opt_val = curr_val; opt_mov = 0; 
                        } 
                        if (opt_mov < v) {
                            sub_opt[opt_mov] = sub_vert; 
                            rest_opt[opt_mov++] = rest_vert;
                        } 
                    } 
                }
                
                /* restore diffs */
                for (l = 0; l < sub_degs[sub_vert]; l++) 
                    diffs[adj_list[sub_vert][l]]++;
            }

            /* reset active columns for next move and update minimal value */
            for (k = 0; k < u_cols; k++) u_ch[u_list[k]] = 0;
            old_min_val = new_min_val;
        }

        /* update statistics and output global minium */
        glob_vals += g_opt_val; tot_mov += j;
        if (i % VALS_PER_LINE == 0) printf("\n");
        printf("%d ", g_opt_val); fflush(stdout);
        
        /* output subgraph information, if desired */
        temp = show_sols; if (temp < 0) temp = -temp;
        if (g_opt_val < temp) {
            printf("\n\n");
            for (k = 0; k < v; k++) if (opt_ch[k]) printf("%d ", k);
            printf("\n\n");

            /* output adjacency and degree information */
            if (show_sols < 0) {
                for (degree = k = 0; k < v; k++) 
                    if (opt_ch[k]) {
                        for (l = sub_degs[k] = 0; l < degs[k]; l++) {
                            vert = adj_list[k][l];
                            if (opt_ch[vert]) {
                                sub_degs[k]++;
                                if (vert > k) printf(" %d", vert);
                            }
                        }
                        printf("-1\n"); degree += sub_degs[k];
                    }
                printf("\nV = %d, E = %d\n\n", v_sub + v_fix, degree / 2);
            }
        } 

        /* reset subgraph vertices for next experiment */
        for (k = 0; k < v_sub; k++) sub_ch[sub_verts[k]] = 0;
    }

    /* output search statistics, timing information and host name */ 
    printf("\n\n%d : ", succ_exp); if (!succ_exp) succ_exp = 1;
    for (i = 0; i < NUM_BOXES; i++) printf("%d ", boxes[i]); 
    printf("\n%d %d %g ", succ_mov / succ_exp, tot_mov / succ_exp, 
           (double)glob_vals / num_exps); showtimings(stdout);
        
    /* deallocate memory */ 
    for (i = 0; i < v; i++) { free(adj[i]); free(adj_list[i]); } free(u_list);
    free(adj); free(adj_list); free(sub_verts); free(rest_verts); free(diffs);
    free(sub_opt); free(rest_opt); free(degs); free(sub_degs); free(boxes);
    free(vert_inds); free(sub_ch); free(opt_ch); free(u_ch); free(rand_perm); 

    exit(EXIT_SUCCESS);
}
