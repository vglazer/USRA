# Stochastic Graph Search

## Overview
Some 
[combinatorial designs](https://en.wikipedia.org/wiki/Combinatorial_design) 
lack algebraic structure and require constructive proofs
to settle existence. The problem can be reduced to finding [induced
subgraphs](https://en.wikipedia.org/wiki/Induced_subgraph) with a 
prescribed edge count in various kinds of graphs. We provide a suite of 
efficient 
[stochastic local search](https://www.researchgate.net/publication/283825846_Stochastic_Local_Search_Algorithms_An_Overview) 
algorithms for doing so, based on Fred Glover's
[Tabu search](https://en.wikipedia.org/wiki/Tabu_search)
[metaheuristic](https://en.wikipedia.org/wiki/Metaheuristic) (an alternative to simulated annealing)
and [implemented in C](https://github.com/vglazer/USRA/tree/master/subgraph_finding/src). 
See [report](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/README.md) for details

## Build Instructions
You will need `make` and `gcc`. To install these on Ubuntu, run
`sudo apt-get install build-essential` in a terminal window. If you are on 
MacOS, use `xcode-select --install` instead.

To build everything, just run `make` in the top-level directory. This will 
create a `bin` subdirectory containing the various graph search programs. 
There are no external library dependencies, so with a bit of luck 
everything should work out of the box.

## Usage
The graph search programs read from standard input (`STDIN`) and 
write to standard output (`STDOUT`), much like 
[UNIX filters](https://en.wikipedia.org/wiki/Filter_(software)#Unix). 
While this can be confusing at first -- particularly given that no usage 
info is printed to the console and no `man` pages are available -- the 
examples provided in the 
[report](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/README.md)
should hopefully clear things up.
