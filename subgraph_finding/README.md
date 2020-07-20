# Stochastic Graph Search

## Overview
Some 
[combinatorial designs](https://en.wikipedia.org/wiki/Combinatorial_design) 
lack algebraic structure and require constructive proofs
to settle existence. The problem can be reduced to finding [induced
subgraphs](https://en.wikipedia.org/wiki/Induced_subgraph) with a 
prescribed edge count in various kinds of graphs. 

We provide a suite of efficient 
[stochastic local search](https://www.researchgate.net/publication/283825846_Stochastic_Local_Search_Algorithms_An_Overview) 
algorithms [implemented in C](https://github.com/vglazer/USRA/tree/master/subgraph_finding/src)
for doing so, based on Fred Glover's [Tabu search](https://en.wikipedia.org/wiki/Tabu_search)
[metaheuristic](https://en.wikipedia.org/wiki/Metaheuristic) 
(an alternative to simulated annealing). This work was supervised by 
[Rudi Mathon](http://www.cs.toronto.edu/dcs/people-faculty-combin.html).

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
write to standard output (`STDOUT`), in the style of 
[UNIX filters](https://en.wikipedia.org/wiki/Filter_(software)#Unix). 
There is no usage info printed to the console and no `man` pages, 
but the examples provided in the 
[reports](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/README.md)
should hopefully clear things up.
