# GGEN.C REPORT

## PURPOSE
[`ggen.c`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/src/ggen.c) 
grew out of the need to generate and manipulate unweighted, undirected
graphs of various types in order to gauge the performance `sub_search`, 
`reg_search` and their derivatives (not including `wsub_search`, which has its own graph generator, called `wggen`). 

When working with the `*search` family of 
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
Like the `*search` programs, `ggen` reads from standard input and writes to 
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
first set `graph_type` to 2, for the second set it to 3 and for the last set it
to 4. In general, density can be set to any non-negative integer between 0 and
1000; a graph of density `d` has approximately `d * v * (v - 1) / 2000` edges (recall that the complete graph on `v` vertices has `v * (v - 1) / 2` edges). 
Realistically however, both power and geometric graphs can only attain 
densities below 500. 

Alternatively, `ggen` can work with existing graphs, input as either `'-1'` 
terminated adjacency lists or as `'-1'` terminated incidence lists. `graph_type`
should be set to 0 for the former and 1 for the latter. When working with 
incidence lists, v is interpreted as the number of symbols. |num\_sets| must
equal the number of sets; when num\_sets is negative the dual of the list is
considered (i.e. the sets become the vertices). density, which is ignored when 
`graph_type` is 0, indicates either the number of sets a pair of vertices must 
appear in together to be adjacent (primal), or the number of vertices two sets
must intersect in to be adjacent (dual). 

Once a graph is input, four types of subgraphs can be induced and a switching 
can be performed with respect to some specified vertex subset `Fixed`. Set 
`num_fixed` to `|Fixed|` and list the vertices (in no particular order) after the 
adjacency or incidence list is input. If one does not wish to fix any vertices,
`num_fixed` should be set to 0. The `fixed_type` parameter determines how the 
fixed vertices will be used. Set it to 1 to induce a subgraph on `Fixed`, -1 to 
induce it on `V \ Fixed`, 2 to induce it on the common neighbourhood of 
`Fixed` (i.e. vertices of `V` adjacent to each and every vertex of `Fixed`), 
-2 to do so on the common non-neighbourhood of `Fixed` (i.e. vertices of `V` 
not adjacent to any vertex in `Fixed`) and finally 3 in order to switch the 
graph with respect to `Fixed` (i.e. turn the appropriate edges into 
non-edges and vice versa). Note that the vertices of the induced subgraph are 
renumbered from 0 to `v_sub`; their original labels are listed above the 
adjacencies.

The output consists of a `'-1'` terminated adjacency list followed by the vertex
and edge counts of the graph and its degree spectrum, where by degree spectrum 
we mean the number of times each of the vertex degrees that appears in the 
graph occurs in it.

When the `compl` flag is set to 0, the adjacency list is output as is. When it is
set to 1, on the other hand, the complement is output instead. This option 
particularly handy when the graph is dense: the complement is sparse and thus 
consumes far less space.

## DATA STRUCTURES
The only data structure of note is `adj`, a standard 0-1 adjacency matrix. When 
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
      num_fixed to 0 (`fixed_type`, set to 0 here, is ignored).

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
      `graph_type` is 0, density and seed are both ignored (we set them to 0 to 
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
      of the subgraph induced on `V \ Fixed`, where `Fixed` consists of the 10
      fixed vertices indicated.

VIII. `1 50 -5000 10 0  1 2  0`

      [ `'-1'` terminated incidence list omitted to save space ]

      4200

      Input a 5000 set incidence list on 50 symbols and consider its dual, i.e.
      let the sets be the vertices and make every pair of sets that intersect 
      in 10 elements adjacent. Output the subgraph induced on the common 
      neighbourhood of the single fixed vertex indicated, i.e. its first 
      neighbourhood.
