# SUB\_SEARCH.C REPORT

## PURPOSE
`sub_search.c` uses randomised restricted local search to find vertex-induced 
subgraphs with a prescribed edge count in undirected, unweighted graphs. The
importance of `sub_search` is that it is subsequently used as a basic framework
for a number of other programs, including `asub_search`, `wsub_search`, `reg_search` and `ereg_search`.

## METHOD
Similarly to UNIX 'filters', `sub_search` reads from standard input and writes to standard output, both of which can be redirected as needed using standard shell facilities. The input parameters are:

```
   v         | number of graph vertices
   v_sub     | number of subgraph vertices 
   e_sub     | number of subgraph edges 
   v_fix     | number of fixed vertices, if any
   num_exps  | number of experiments to perform
   num_moves | maximum allowed number of moves per experiment
   div_freq  | diversification frequency, in moves (how often to shake)
   div_dur   | diversification duration, in moves (how long to shake for)
   seed      | random seed, a non-negative integer
   show_sols | output format
```

The graph to be searched is input as a `'-1'` terminated adjacency list (in fact, there is no need to supply the entire list; only the upper or only the lower 
portion will both do, since the adjacency matrix is symmetric by definition). 
In order to improve performance, both the adjacency matrix and the adjacency 
list are stored. 

At the start of a new experiment, `v_sub` subgraph vertices are selected at 
random. Each move, a neighbourhood of the current subgraph, defined by a 
single interchange between a subgraph vertex and an outside vertex, is examined
in order to generate a list of swaps that minimise the linear objective 
function `f(e) = | e - e_sub |`, where `e` and `e_sub` are the actual and desired edge counts respectively. A locally optimal move is then randomly selected from that list and the subgraph updated to reflect it. Once in every `diver_freq` 
moves, `diver_freq` random moves are made in order to perturb the graph a little. Empirical evidence suggests that such perturbations can considerably improve 
search quality. 

For large, dense graphs examining the entire neighbourhood can
be prohibitively expensive. It has been experimentally determined that, when 
the objective function value remains unchanged for two consecutive moves, it is
sufficient (and, moreover, advantageous) to examine only a portion of the 
neighbourhood, namely the symmetric difference of the first neighbourhoods of 
the two vertices being swapped (i.e. vertices adjacent to one or the other but
not to both). This restriction, which has been shown to markedly improve search
quality, gives rise to the term "restricted local search" mentioned above. 
Additionally, irrespective of whether or not the objective function value has 
changed, we exclude all moves involving the vertices just swapped from 
consideration. This is done to minimise "cycling" (whereby a pair of vertices 
are swapped twice, undoing the changes to the subgraph). 

Each experiment, the objective function minimum attained is output, along with 
additional information determined by the value of the output format flag.
If the flag is set to 0, no additional information is output; if the flag is 
set to n, n > 0, the vertices of the subgraph that attained the global minimum
are output whenever the minimum is < n; if the flag is set to n, n < 0, both 
the vertices and the adjacencies of the subgraph that attained the global 
minimum (as well as its vertex and edge counts) are output whenever the minimum
is < |n|. One can use `sub_search` as an approximation algorithm by setting the
output format flag to n, where |n| > 1. Whenever the global minimum attained 
during an experiment is less than |n|, information about the subgraph which 
attained that minimum will be output. This includes not only exact solutions, 
but also approximate solutions with up to |n - 1| "conflicts". 

After the specified number of experiments is performed, the following is 
output: the total number of successful experiments, a "box distribution", 
three statistical indicators, CPU time used (in seconds) and the name of the 
host machine. 

The "box distribution", used as a guide when adjusting the 
`num_moves` parameter, is obtained as follows: the interval `[1, num_moves]` is 
partitioned into `NUM_BOXES` subintervals of equal length, or "boxes"; every 
successful experiment then contributes 1 to the appropriate box (e.g. if 
`num_moves` is 1000 and `NUM_BOXES` is 10, a successful experiment where the 
solution was found in 220 moves will go into box 3). If the majority of the 
experiments gravitate towards the first few boxes, `num_moves` can be lowered. 
Conversely, if they are mostly huddled in the last few, `num_moves` can be 
increased. Ideally, we'd like to see a normal (bell-shaped) distribution. 

The three statistical indicators are referred to as "relative cost", "true cost" and "average conflict", respectively. The first two are intended to measure how
"difficult to find" a particular subgraph is. The relative cost represents the
number of moves required to find a solution, averaged over successful 
experiments. The true cost also represents the number of moves required to find
a solution, but this time averaged over both successful and unsuccessful 
experiments. The average conflict is simply the objective function minimum 
attained, averaged over all experiments. It is 0 when all experiments are 
successful, and is used to evaluate parameter settings (the goal being getting 
it as close to 0 as possible).

## DATA STRUCTURES
Since the subgraph problem is NP-complete, the algorithm cannot be expected 
to perform well asymptotically. However, every effort was made to improve 
performance for practical input sizes, sometimes at the expense of using 
additional storage. The main data structures are:

`adj`, `adj_list`: the adjacency matrix, represented as a rectangular character 
array, and adjacency list, represented as a double array of integers (which 
generally isn't rectangular). The rationale behind the somewhat extravagant 
decision to store the matrix as well as the list (after all, any graph of 
density greater than 50% can be made sparser through complementation) is that 
the O(1) access provided by the former and the performance boost it translates
into trumps space considerations.

`degs`, `sub_degs`: integer arrays containing the overall degree and the degree 
with respect to the current subgraph of every vertex. The former is required
to properly traverse the adjacency list, while the latter is used in computing
the objective function value.

`sub_ch`, `opt_ch`, `sub_verts`, `rest_verts`, `vert_inds`: `sub_ch` is a character array used as a characteristic vector for subgraph vertices, allowing one to
determine subgraph membership in O(1) time. Each time a subgraph that improves
the global objective function minimum is found, its characteristic vector is 
copied into `opt_ch`. `sub_verts` and `rest_verts` are integer arrays which list, in no particular order, the vertices inside and outside the current subgraph, 
respectively. The two are used to efficiently process subgraph and non-subgraph
vertices; both v\_sub and v\_rest are guaranteed to be smaller than v (since 
v = v\_sub + v\_rest), so this is preferable to using `sub_ch`. `vert_inds` is an integer array that stores the position (or index) of every vertex in its 
corresponding list (`sub_verts` if the vertex is inside the subgraph, `rest_verts` otherwise). This allows vertices to be interchanged in O(1) time, eliminating
the need for costly linear searching (which would have been necessary, since
the lists are unsorted).

`u_ch`, `u_list`: when selecting optimal moves, a v\_sub by v\_rest matrix whose entries are objective function values (i.e. the ijth entry is the value
of the subgraph obtained by swapping the ith subgraph vertex with the jth non-
subgraph vertex) representing the entire neighbourhood is formed implicitly.
Instead of examining the entire matrix however, we restrict our attention to
selected rows and columns, referred to as "active rows" and "active columns"
respectively. Since each vertex is either inside the subgraph or outside it,
a single character array of length v, `u_ch`, can serve as a characteristic 
vector for both active rows and columns. In an active row, only the active 
columns in it are examined; in an inactive one all columns are (the row and 
column corresponding to the two vertices just swapped are never active). The 
integer array `u_list` lists all columns, inactive ones first. In an active row,
we process the latter part of the list only; otherwise, the entire list
is processed.

`sub_opt`, `rest_opt`: these integer arrays are used to store the inner and 
outer vertices of optimal moves (i.e those that belong to the subgraph and 
those that do not, respectively). Although there could potentially be as many
as v\_sub * v\_rest (which is O(v^2)) optimal moves, both `sub_opt` and `rest_opt` are declared to be of size v. This does not seem to affect search quality 
adversely, and it saves a considerable amount of space.

## EXAMPLES
I.   `100 31 0 0  50 1000 250 4 1  0` 

     [ '-1' terminated adjacency list omitted to save space ]
   
     Search for 31-cocliques in a graph on 100 vertices, with no fixed vertices
     specified. Perform 50 experiments, at most 1000 moves each. Every 250 
     moves, make 4 random (diversification) moves. Use 1 as the random 
     seed. For each experiment, display only the global objective function 
     minimum attained (to avoid displaying vertex and adjacency information, 
     one should set the output format flag to 0).

II.  `67 4 6 2  2000 500 1 0 26  5` 

     [ '-1' terminated adjacency list omitted to save space ]
     
     61 63

     Search for 4-cliques through two fixed vertices, 61 and 63, in a graph on
     67 vertices. Perform 2000 experiments, at most 500 moves each. Do not make
     any random moves (note that to turn diversification off, one sets the
     duration, and not the frequency, to 0; the frequency _must_ be non-zero). 
     Use 26 as the random seed. For each experiment, display the global 
     objective function minimum attained. Additionally, for every experiment 
     where the above minimum was 4 or below, display the vertices of the 
     subgraph that attained it. 

III. `1000 47 153 1  25 5000 1000 250 3782  -1`

     [ '-1' terminated adjacency list omitted to save space ]

     872

     Search for 47-vertex, 153-edge subgraphs through a single fixed vertex,
     872, in a graph on 1000 vertices. Perform 25 experiments, at most 5000
     moves each. Every 1000 moves, make 250 random moves. Use 3782 as the 
     random seed. For each experiment, display the global objective function 
     minimum attained. Additionally, for every successful experiment (i.e. one
     where the aforementioned minimum is 0), display the vertices and 
     adjacencies of the subgraph that attained it, along with a vertex and 
     edge count (note the use of the negative output format flag).
