# WGGEN REPORT

## PURPOSE
[`wggen.c`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/src/wggen.c) 
generates undirected, weighted exponential (Erdos-Szekeres) random 
graphs with a prescribed density (where the density is defined to be `d = (200 * e) / (v * (v - 1)))`. 
As in `ggen`, the input parameters are read in from 
standard input, and the resulting graphs are then written to standard output 
as `'-1'` terminated adjacency lists in the format used by `wsub_search` (see 
`wsub_search_report.txt` for details). 

However, `wggen` has none of `ggen`'s advanced features. It is only capable of generating random graphs of one type (the 
simplest kind, in fact), and cannot manipulate existing ones.

## METHOD
Unlike in `ggen`, command line arguments are used for input; the output is written to standard output as before, however. The input parameters are the number of vertices, the desired density and the random seed to be used. 

First, the total number of edges corresponding to the desired density is 
computed from the definition (i.e. `e = v * (v - 1) * d / 200`). Then, the 
adjacency matrix is formed by initialising all entries to 0 and incrementing 
`e` randomly selected ones. Entries that are "hit" once are understood to have
unit weight; those hit multiple times have weights 2 and above. Although the 
density should be non-negative, it need not be less than 100, since a graph
with a total weight of `v * (v - 1) / 2` is extremely unlikely to be complete
(because many edges will no doubt be hit multiple times, leading to weights 
greater than 1). A graph with density `100 * n` will essentially have `n` times the
total weight of the unit weight complete graph on the same number of vertices.

## DATA STRUCTURES
The only data structure of note is the adjacency matrix, `adj`. It is identical
in format to the one used in `wsub_search` (see the 
[`wsub_search` report](https://github.com/vglazer/USRA/blob/master/subgraph_finding/src/wsub_search.c) 
for details). As in `ggen`, the adjacency list is never formed explicitly. 
 
## EXAMPLES
I.  `200 65 1`
 
    Generate a 200-vertex exponential random graph with density 65. Use 1 as 
    the random seed.

II. `1500 300 72`

    Generate a 1500-vertex exponential random graph with density 300. Use 72 
    as the random seed.

