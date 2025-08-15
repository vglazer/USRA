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
There are no external library dependencies, so with luck 
everything should work out of the box.

## Usage
The graph search programs read from standard input (`STDIN`) and 
write to standard output (`STDOUT`), in the style of 
[UNIX filters](https://en.wikipedia.org/wiki/Filter_(software)#Unix). 
There is no usage info printed to the console and no `man` pages, 
but the examples provided in the 
[reports](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/README.md)
should hopefully clear things up. 

The syntax of `ggen` and `sub_search` if flexible, but a little unusual. One thing to watch out for is that *the raw output of `ggen` _cannot_ be piped directly into `sub_search`*. Everything other than the `'-1'`-terminated adjacency matrix must first be either removed manually or filtered out, which is the reason for the `grep` in the Quickstart section below.

## Quickstart
The typical workflow is to generate a random graph of some type using `ggen` and then look for interesting induced subgraphs in it (like k-cliques, say) using `sub_search`. 

Assuming you are in the top-level directory and successfully followed the instructions in the Build Instructions section above, you can save both the graph and the experiment results to plain text files, like so (2-step approach):
```
echo "2 100 0 600 2  0 0  0" | ./bin/ggen | grep '\-1$' > graph.txt
(echo 100 8 0 0  60 100 25 4 1  0; cat graph.txt) | ./bin/sub_search >
summary.txt
(echo 100 8 0 0  60 100 25 4 1  1; cat graph.txt) | ./bin/sub_search > details.txt
```
`summary.txt` only shows how close `sub_search` came to finding the desired subraph in each experiment, whereas `details.txt` also contains the subgraph's vertices for experiments where it was actually found (the edges are implied, given that the subgraph is induced).

Alternatively, you can pipe the output of `ggen` directly into `sub_search` - **after filtering out everything but the adjacency matrix** - and either dump the results to standard output or redirect them to a file, like so (1-step approach):
```
(echo 100 8 0 0  60 100 25 4 1  0; echo "2 100 0 600 2  0 0  0" | ./bin/ggen | grep '\-1$') | ./bin/sub_search
(echo 100 8 0 0  60 100 25 4 1  0; echo "2 100 0 600 2  0 0  0" | ./bin/ggen | grep '\-1$') | ./bin/sub_search > summary.txt
(echo 100 8 0 0  60 100 25 4 1  1; echo "2 100 0 600 2  0 0  0" | ./bin/ggen | grep '\-1$') | ./bin/sub_search
(echo 100 8 0 0  60 100 25 4 1  1; echo "2 100 0 600 2  0 0  0" | ./bin/ggen | grep '\-1$') | ./bin/sub_search > details.txt
```
One benefit of the 1-step approach is that you avoid having to store the graph, which may in general be large, until you actually find some interesting subgraphs. If you do, you can re-run `ggen` with the same arguments and redirect the output to a file, as in the earlier examples. The resulting random graph will be the same, as long as you use the same seed.