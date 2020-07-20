# EREG\_SEARCH REPORT

## PURPOSE
[`ereg_search.c`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/src/ereg_search.c), 
like [`reg_search.c`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/src/reg_search.c), uses randomised restricted local search to find regular vertex-induced subgraphs with a prescribed valency in undirected,
unweighted graphs.

## METHOD
The input parameters and output are identical to those of `reg_search` (see 
the [`reg_search` report](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/reg_search.md) for details). This time, however, each experiment is 
divided into two phases. 

First, we find a subgraph with the desired number 
of edges (i.e. `v_sub * d_sub / 2`) using the objective function from `sub_search`. This phase is usually quite fast, since the objective function is relatively simple and there is no need to partition the adjacencies. If no such subgraph 
is found, the experiment fails; otherwise, we move on to phase two. In this 
phase, we attempt to find a "nearby" regular subgraph with the desired valency
using the objective function from `reg_search`. This phase typically lasts 
longer, since the objective function is more cumbersome to work with and the
partitioning of the adjacencies must be updated each move. 

As one might expect,
`ereg_search` performs no better (and sometimes even worse) than `reg_search`, 
since a large portion of the subgraphs found in phase one may turn out not to 
be regular. Though not terribly useful from a practical perspective, the 
stratification of objective functions, important in some applications, makes it
interesting theoretically.

## DATA STRUCTURES
The data structures are an amalgamation of those used in `sub_search` and 
`reg_search` (see the [`sub_search` report](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/sub_search.md) 
and [the `reg_search` report](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/reg_search.md) for details).

## EXAMPLES
See the [`reg_search`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/reg_search.md) report.
