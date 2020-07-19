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
