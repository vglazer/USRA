# WSUB\_SEARCH REPORT

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
