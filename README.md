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

---

# ASUB\_SEARCH.C REPORT

## PURPOSE
`asub_search.c`, like `sub_search.c`, uses randomised restricted local search to 
find vertex-induced subgraphs with a prescribed edge count in undirected, 
unweighted graphs. It introduces limited aspiration, i.e. some of the 
restricted moves that improve the global objective function minimum are 
considered.

## METHOD
The input parameters and output are identical to those of `sub_search`, and the 
overall approach is very similar (see `sub_search_report.txt` for details). The 
difference is that moves involving one or both of the two vertices most 
recently swapped are not ruled out completely. Instead, such moves are appended
to a separate list whenever they improve the global objective function minimum,
and a single move is then randomly selected from it. This process, known as 
"aspiration", can sometimes improve the quality of the search. 

Note that only a very small portion of all restricted moves, which are given by the symmetric difference of the first neighbourhoods of the two vertices most recently swapped, are considered for aspiration. This what makes the aspiration 
"limited". Also note that in our implementation, aspiration moves take 
precedence over locally optimal moves. This means that an aspiration move will
be made whenever the corresponding list is non-empty, even if the locally 
optimal move would have also improved the global minimum. This was a conscious 
design decision intended to magnify the effects of the aspiration, such as they
are.

## DATA STRUCTURES
The data structures used are largely the same as in `sub_search` (see 
`sub_search_report.txt` for details). The only two additions are the integer 
arrays `sub_asp` and `rest_asp`, which store the inner and outer vertices of 
aspiration moves (i.e. those that belong to the subgraph and those that do not,
respectively).

## EXAMPLES
See `sub_search_report.txt`.

---

# WSUB\_SEARCH.C REPORT

## PURPOSE
`wsub_search.c` uses randomised restricted local search to find vertex-induced 
subgraphs with a prescribed edge count in undirected, weighted graphs (where
the weights are assumed to be small integers)

## METHOD
The input parameters and output are identical to those of `sub_search`, and the
overall approach is very similar (see `sub_search_report.txt` for details). 

However, the format of the adjacency list has been modified somewhat to allow
for the encoding of edge weights: if the ith row of the adjacency list 
contains entry x, then {i, (x % v)} is an edge with weight (x / v) + 1. In 
other words, if there is an edge of weight w between i and j, we add entry
j + (w - 1) * v to the ith row of the adjacency list. We chose to use w - 1 
instead of w so that unit weights would reduce to the standard adjacency 
list format, allowing `wsub_search` to be used for unweighted graphs also. 

A few additional changes to `sub_search` were required, most concerning the 
computation of the objective function and inner degree (i.e. the degree with
respect to subgraph vertices only).

## DATA STRUCTURES
The data structures used are largely the same as in `sub_search` (see 
`sub_search_report.txt` for details). However, the format of the adjacency 
matrix, adj, is a bit different. The entries are no longer restricted to being
either 0 or 1, but rather represent the weight of the corresponding edge (non-edges being understood to have weight 0). 

Internally, the format of the adjacency list, `adj_list`, remains unchanged for reasons of efficiency. Whenever subgraph adjacencies are output (i.e. if the output format flag is negative), they are modified on the fly to conform to the new format.

## EXAMPLES
The examples provided in `sub_search_report.txt` are largely still valid, though their interpretation is slightly different. For one, a 4-vertex graph with a 
single edge of weight 6 is still a "4-clique", as far as our implementation is 
concerned; also, the omitted adjacency lists could now encode weighted graphs
using the format outlined above.

---

# REG\_SEARCH.C REPORT

## PURPOSE
`reg_search.c` uses randomised restricted local search to find regular vertex-induced subgraphs with a prescribed valency in undirected, unweighted graphs.

## METHOD
The input parameters are nearly identical to those of `sub_search`, except that 
e\_sub, the desired edge count, is now replaced by d\_sub, the desired valency; 
the output is exactly the same as in `sub_search` (see `sub_search_report.txt` for details). This time, however, the objective function being minimised is 
f(V\_sub) = Sum(| sub\_degree(v) - d\_sub |), where V\_sub stands for subgraph
vertices and sub\_degree stands for inner degree, or degree with respect to 
subgraph vertices only. 

Although `reg_search`, like `sub_search`, can be used to find cliques and cocliques (which have valency v - 1 and 0 respectively), it is
ill-suited for that purpose due to the considerable speed penalty imposed by 
the more complicated objective function. The intended use of `reg_search` is to 
find regular subgraphs in strongly regular graphs. The strongly regular graph 
can then be "switched" with respect to the subgraph in question, creating
a new, larger strongly regular graph.

## DATA STRUCTURES
The data structures used are largely the same as in `sub_search` (see 
`sub_search_report.txt` for details). 

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

---

# EREG\_SEARCH.C REPORT

## PURPOSE
`ereg_search.c`, like `reg_search.c`, uses randomised restricted local search to find regular vertex-induced subgraphs with a prescribed valency in undirected,
unweighted graphs.

## METHOD
The input parameters and output are identical to those of `reg_search` (see 
`reg_search_report.txt` for details). This time, however, each experiment is 
divided into two phases. First, we find a subgraph with the desired number 
of edges (i.e. v\_sub * d\_sub / 2) using the objective function from `sub_search`. This phase is usually quite fast, since the objective function is relatively simple and there is no need to partition the adjacencies. If no such subgraph 
is found, the experiment fails; otherwise, we move on to phase two. In this 
phase, we attempt to find a "nearby" regular subgraph with the desired valency
using the objective function from `reg_search`. This phase typically lasts 
longer, since the objective function is more cumbersome to work with and the
partitioning of the adjacencies must be updated each move. As one might expect,
`ereg_search` performs no better (and sometimes even worse) than `reg_search`, 
since a large portion of the subgraphs found in phase one may turn out not to 
be regular. Though not terribly useful from a practical perspective, the 
stratification of objective functions, important in some applications, makes it
interesting theoretically.

## DATA STRUCTURES
The data structures are an amalgamation of those used in `sub_search` and 
`reg_search` (see `sub_search_report.txt` and `reg_search_report.txt` for details).

## EXAMPLES
See `reg_search_report.txt`.

---

# GGEN.C REPORT

## PURPOSE
`ggen.c` grew out of the need to generate and manipulate unweighted, undirected
graphs of various types in order to gauge the performance `sub_search`, 
`reg_search` and their derivatives (not including `wsub_search`, which has its own graph generator, called `wggen`). When working with the \*search family of 
programs, it is often helpful to isolate a particular subgraph. Features for 
inducing subgraphs on fixed vertices, their complement, common neighbourhood 
and non-neighbourhood were therefore added. Also, it is sometimes beneficial to
work with a graph's complement rather than searching for a solution directly. A
complementation option was added to facilitate this. Furthermore, many 
interesting graphs can be obtained from incidence lists (which are a 
generalisation of adjacency lists), so facilities for inputting such lists 
were added. Finally, since switchings in strongly regular graphs constitute an
important application, a graph switching option was included.

## METHOD
Like the \*search programs, `ggen` reads from standard input and writes to 
standard output. The input parameters are:

```
   graph_type | one of five graph types, see below
   v          | number vertices (adjacency lists) or symbols (incidence lists) 
   num_sets   | number of sets (incidence lists only)
   density    | graph density (random graphs only)
   seed       | random seed, a non-negative integer
   num_fixed  | number of fixed vertices, if any
   fixed_type | one of five fixed types, see below
   compl      | complementation flag
```

`ggen` is capable of generating three different types of random graphs with a
prescribed density from scratch: exponential (Erdos-Szekeres), power (scale-free) and geometric (in the plane, with no wrap-around). To select the 
first set graph\_type to 2, for the second set it to 3 and for the last set it
to 4. In general, density can be set to any non-negative integer between 0 and
1000; a graph of density d has approximately d * v * (v - 1) / 2000 edges. 
Realistically however, both power and geometric graphs can only attain 
densities below 500. 

Alternatively, `ggen` can work with existing graphs, input as either `'-1'` 
terminated adjacency lists or as `'-1'` terminated incidence lists. graph\_type
should be set to 0 for the former and 1 for the latter. When working with 
incidence lists, v is interpreted as the number of symbols. |num\_sets| must
equal the number of sets; when num\_sets is negative the dual of the list is
considered (i.e. the sets become the vertices). density, which is ignored when 
graph\_type is 0, indicates either the number of sets a pair of vertices must 
appear in together to be adjacent (primal), or the number of vertices two sets
must intersect in to be adjacent (dual). 

Once a graph is input, four types of subgraphs can be induced and a switching 
can be performed with respect to some specified vertex subset Fixed. Set 
num\_fixed to |Fixed| and list the vertices (in no particular order) after the 
adjacency or incidence list is input. If one does not wish to fix any vertices,
num\_fixed should be set to 0. The fixed\_type parameter determines how the fixed vertices will be used. Set it to 1 to induce a subgraph on Fixed, -1 to induce
it on V \ Fixed, 2 to induce it on the common neighbourhood of Fixed (i.e. 
vertices of V adjacent to each and every vertex of Fixed), -2 to do so on the 
common non-neighbourhood of Fixed (i.e. vertices of V not adjacent to any 
vertex in Fixed) and finally 3 in order to switch the graph with respect to 
Fixed (i.e. turn the appropriate edges into non-edges and vice versa). Note 
that the vertices of the induced subgraph are renumbered from 0 to v\_sub; 
their original labels are listed above the adjacencies.

The output consists of a `'-1'` terminated adjacency list followed by the vertex
and edge counts of the graph and its degree spectrum, where by degree spectrum 
we mean the number of times each of the vertex degrees that appears in the 
graph occurs in it.

When the compl flag is set to 0, the adjacency list is output as is. When it is
set to 1, on the other hand, the complement is output instead. This option 
particularly handy when the graph is dense: the complement is sparse and thus 
consumes far less space.

## DATA STRUCTURES
The only data structure of note is adj, a standard 0-1 adjacency matrix. When 
an existing adjacency or incidence list is input it is converted to an 
adjacency matrix internally, and when a new graph is generated it is the 
adjacency matrix that is filled in. All subsequent manipulations (if any) use 
the matrix in a uniform fashion, which streamlines the code significantly. The
adjacency list is never formed explicitly; instead, it is extracted from the 
adjacency matrix as needed, saving considerable storage.

## EXAMPLES
I.    `2 100 0 600 2  0 0  0`

      Generate and output a 100-vertex exponential random graph of density
      600 (or 60%). Use 2 as the random seed. Since we are not inputting an
      incidence list (i.e. graph_type is not 1), num_sets is ignored (we set it
      to 0 to suggest that). No fixed vertices are specified, so we set 
      num_fixed to 0 (fixed_type, set to 0 here, is ignored).

II.   `3 2500 0 200 52  0 0  1`

      Generate a 2500-vertex power random graph of density 200 and output its 
      complement. Use 52 as the random seed. 

III.  `4 790 0 150 1  0 0  0`

      Generate and output a 790-vertex geometric random graph of density
      150. Use 1 as the random seed.

IV.   `0 100 0 0 0  3 -2  0`

      [ '-1' terminated adjacency list omitted to save space ]

      25 0 7

      Input a graph on 100 vertices and output the subgraph induced on the 
      common non-neighbourhood of the 3 fixed vertices indicated. Since 
      graph_type is 0, density and seed are both ignored (we set them to 0 to 
      suggest that).

V.    `0 1500 0 0 0  5 1  1`

      [ '-1' terminated adjacency list omitted to save space ]

      1200 105 14 21 25

      Input a graph on 1500 vertices and output the complement of the subgraph 
      induced on the 5 fixed vertices indicated.

VI.   `0 30 0 0 0  4 3  0`

      [ '-1' terminated adjacency list omitted to save space ]

      17 5 28 9

      Input a graph on 30 vertices and output the same graph switched with
      respect to the 4 fixed vertices indicated.

VII.  `1 1000 20 2 0  10 -1  1` 

      [ '-1' terminated incidence list omitted to save space ] 

      260 150 37 8 22 13 4 66 2 9

      Input a 20-set incidence list on 1000 symbols and make every pair of
      vertices that appear together in 2 sets adjacent. Output the complement
      of the subgraph induced on V \ Fixed, where Fixed consists of the 10
      fixed vertices indicated.

VIII. `1 50 -5000 10 0  1 2  0`

      [ `'-1'` terminated incidence list omitted to save space ]

      4200

      Input a 5000 set incidence list on 50 symbols and consider its dual, i.e.
      let the sets be the vertices and make every pair of sets that intersect 
      in 10 elements adjacent. Output the subgraph induced on the common 
      neighbourhood of the single fixed vertex indicated, i.e. its first 
      neighbourhood.

---

# WGGEN.C REPORT

## PURPOSE
`wggen.c` generates undirected, weighted exponential (Erdos-Szekeres) random 
graphs with a prescribed density (where the density is defined to be d = 
(200 * e) / (v * (v - 1))). As in `ggen`, the input parameters are read in from 
standard input, and the resulting graphs are then written to standard output 
as `'-1'` terminated adjacency lists in the format used by `wsub_search` (see 
`wsub_search_report.txt` for details). However, `wggen` has none of `ggen`'s advanced features. It is only capable of generating random graphs of one type (the 
simplest kind, in fact), and cannot manipulate existing ones.

## METHOD
Unlike in `ggen`, command line arguments are used for input; the output is written to standard output as before, however. The input parameters are the number of vertices, the desired density and the random seed to be used. 

First, the total number of edges corresponding to the desired density is 
computed from the definition (i.e. e = v * (v - 1) * d / 200). Then, the 
adjacency matrix is formed by initialising all entries to 0 and incrementing 
e randomly selected ones. Entries that are "hit" once are understood to have
unit weight; those hit multiple times have weights 2 and above. Although the 
density should be non-negative, it need not be less than 100, since a graph
with a total weight of v * (v - 1) / 2 is extremely unlikely to be complete
(because many edges will no doubt be hit multiple times, leading to weights 
greater than 1). A graph with density 100 * n will essentially have n times the
total weight of the unit weight complete graph on the same number of vertices.

## DATA STRUCTURES
The only data structure of note is the adjacency matrix, adj. It is identical
in format to the one used in `wsub_search` (see `wsub_search_report.txt` for 
details). As in `ggen`, the adjacency list is never formed explicitly. 
 
## EXAMPLES
I.  `200 65 1`
 
    Generate a 200-vertex exponential random graph with density 65. Use 1 as 
    the random seed.

II. `1500 300 72`

    Generate a 1500-vertex exponential random graph with density 300. Use 72 
    as the random seed.

