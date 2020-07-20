# REG\_SEARCH REPORT

## PURPOSE
[`reg_search.c`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/src/reg_search.c) uses randomised restricted local search to find regular 
vertex-induced subgraphs with a prescribed valency in undirected, 
unweighted graphs.

## METHOD
The input parameters are nearly identical to those of `sub_search`, except that 
`e_sub`, the desired edge count, is now replaced by `d_sub`, the desired valency; 
the output is exactly the same as in `sub_search` 
(see the [`sub_search` report](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/sub_search.md) for details). This time, however, the objective function being minimised is 
`f(V_sub) = Sum(sub_degree(v) - d_sub)`, where `V_sub` stands for subgraph
vertices and `sub_degree` stands for inner degree, or degree with respect to 
subgraph vertices only. 

Although `reg_search`, like `sub_search`, can be used to find cliques and cocliques (which have valency v - 1 and 0 respectively), it is
ill-suited for that purpose due to the considerable speed penalty imposed by 
the more complicated objective function. The intended use of `reg_search` is to 
find regular subgraphs in strongly regular graphs. The strongly regular graph 
can then be "switched" with respect to the subgraph in question, creating
a new, larger strongly regular graph.

## DATA STRUCTURES
The data structures used are largely the same as in `sub_search` (see 
the [`sub_search` report](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/sub_search.md) for details). 

However, the adjacency matrix, `adj`, and 
adjacency list, `adj_list`, were both modified in order to speed up the 
computation of the objective function. Adjacencies are now partitioned into
inner vertices, appearing first, and outer vertices, which follow (both in no
particular order). This enables one to efficiently go through all subgraph 
vertices adjacent to a particular vertex. Unfortunately, it also means that the
partitioning must be updated every time vertices are interchanged (i.e. every
move). In order to accomplish this in O(1) time, entry ij of the adjacency 
matrix now holds the position of j in the adjacencies of i (or -1 if i and j
are not adjacent). 

While this appears to destroy the symmetry of the matrix, it
is in fact still symmetric with respect to negative and non-negative entries.
Naturally, the adjacency matrix itself must also be updated to reflect the 
changes in the adjacencies.

## EXAMPLES
I.  `100 4 2 1  100 500 150 2 7  0`

    [ '-1' terminated adjacency list omitted to save space ]

    0

    Search for 4-cycles through a single fixed vertex, 0, in a graph on 100
    vertices. Perform 100 experiments, at most 500 moves each. Every 150 moves,
    make 2 random moves. Use 7 as the random seed. For each experiment, display
    only the global objective function minimum attained.

II. `5000 150 82 0  30 1000 250 2 3  1`

    [ '-1' terminated adjacency list omitted to save space ]    

    Search for 150-vertex regular subgraphs with valency 82 in a graph on 5000
    vertices, with no fixed vertices specified. Perform 30 experiments, at most
    1000 moves each. Every 250 experiments, make 2 random moves. Use 3 as the
    random seed. For each experiment, display the global objective function 
    minimum attained. Additionally, for every successful experiment, display 
    the vertices of the solution.
