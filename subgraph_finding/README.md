# Stochastic Graph Search

## Overview

Some [combinatorial designs](https://en.wikipedia.org/wiki/Combinatorial_design) lack algebraic structure and require constructive proofs to settle existence. The problem can be reduced to finding [induced subgraphs](https://en.wikipedia.org/wiki/Induced_subgraph) with a prescribed edge count in various kinds of graphs.

We provide a suite of efficient [stochastic local search](https://www.researchgate.net/publication/283825846_Stochastic_Local_Search_Algorithms_An_Overview) algorithms [implemented in C](src) for doing so, based on Fred Glover's [Tabu search](https://en.wikipedia.org/wiki/Tabu_search) [metaheuristic](https://en.wikipedia.org/wiki/Metaheuristic) (an alternative to simulated annealing). This work was supervised by [Rudi Mathon](http://www.cs.toronto.edu/dcs/people-faculty-combin.html).

## Build Instructions

You will need `make` and `gcc`. To install these on Ubuntu, run `sudo apt-get install build-essential` in a terminal window. If you are on MacOS, use `xcode-select --install` instead.

To build everything, simply run `make` with no arguments in the top-level repo directory:

- This will create a `bin` subdirectory containing the various graph search programs. There are no external dependencies, so with luck everything should work out of the box
- It will also run [`etc/graphgen.sh`](etc/graphgen.sh) and save some sample graphs to the `graphs` subdirectory
- `make clean` will delete both `bin` and `graphs`

## Usage

The graph search programs read from standard input (`STDIN`) and write to standard output (`STDOUT`), in the style of  [UNIX filters](https://en.wikipedia.org/wiki/Filter_(software)#Unix). There is no usage info printed to the console and no `man` pages. There are sample commands with explanations provided in the [reports](doc/README.md), though.

The syntax of [`ggen`](doc/ggen.md#method) and [`sub_search`](doc/sub_search.md#method) if flexible, but a little unusual. One thing to watch out for is that *the raw output of `ggen` _cannot_ be piped directly into `sub_search`*. Everything other than the `'-1'`-terminated adjacency matrix must first be either removed manually or filtered out, which is the reason for the `grep` in the Quickstart section below.

## Generating random graphs

The typical workflow is to generate a random graph of some type using [`ggen`](doc/ggen.md#method) or its friendlier wrapper [ggen.sh](etc/ggen.sh) and then look for interesting induced subgraphs in it using [`sub_search`](doc/sub_search.md#method).

Unlike ggen, ggen.sh cannot operate on existing adjacency and incidence lists, but it has a more traditional syntax:

- `ggen.sh` will automatically save the graphs it generates to `graphs/unweighted`, so that you don't need to manually `grep` out the adjacency list from the `ggen` output
- It also dumps only the stats to the console and not the adjacency matrix
- If `graphs/unweighted` does not exist (because you didn't run `graphgen.sh` directly or via `make`), `ggen.sh` will create it
- However, `ggen.sh` won't build `ggen` for you, so run `make` or `make ggen` before running it

Here is the usage info, which contains some sample commands:

```
Usage: ggen.sh graph_type v density [seed] [compl]

Arguments:
  graph_type   Type of graph to generate (2: exponential, 3: power, 4: geometric)
  v            Number of vertices
  density      Graph density (0 <= density <= 1000)
  seed         Optional random seed (a positive integer), default: 1
  compl        Optionally take the complement of the graph (0 or 1), default: 0

Examples:
  exponenital, 100  vertices,  density 600, seed 1,  don't complement: ggen.sh 2 100  600
  exponenital, 100  vertices,  density 600, seed 2,  don't complement: ggen.sh 2 100  600 2
  exponenital, 100  vertices,  density 600, seed 2,  take complement:  ggen.sh 2 100  600 2  1
  power,       2500 vertices,  density 200, seed 52, take complement:  ggen.sh 3 2500 200 52 1
  geometric,   790  vertices,  density 150, seed 1,  don't complement: ggen.sh 4 790  150 1

Graphs are saved to graphs/unweighted as ggen_type_v_density_seed_compl.txt
```

For example, if you run `etc/ggen.sh 3 2500 200 52 1`:

- `ggen.sh` will save the adjacency matrix for the resulting power random graph to `graphs/unweighted/ggen_3_2500_200_52_1.txt`, creating `graphs/unweighted` if it doesn't exit already
- It will also dump the number of edges $E$, along with the degree distribution, to the console
- In this case $E = 2975$, which makes sense because we asked for $60\%$ of the $100*(100 - 1)/2 = 4950$ possible edges to be present (density 600) and $4950 \cdot 0.6 = 2970 \approx 2975$.

### Some graphs to get your started

If you run [`etc/graphgen.sh`](etc/graphgen.sh) with no arguments, it will generate some (unweighted) random graphs using [`ggen`](doc/ggen.md) as well as weighted random graphs using [`wggen`](doc/wggen.md) and save them to `graphs/unweighted` and `graphs/weighted`, respectively.

You can then use these graphs in your [`sub_search`](doc/sub_search.md) and [`wsub_search`](doc/wsub_search.md) experiments, like so:

```
(echo 100 8 0 0  60 100 25 4 1  1; grep '\-1$' graphs/unweighted/exponential_100.\txt) | ./bin/sub_search

(echo 200 8 0 0  60 100 25 4 1  1; grep '\-1$' graphs/weighted/exponential_200.txt) | ./bin/wsub_search
```

## Advanced Usage

### Persisting ggen output to disk

Assuming you are in the top-level directory and successfully followed the instructions in the Build Instructions section above, you can save both the graph and the experiment results to plain text files, like so (2-step approach):

```
echo "2 100 0 600 2  0 0  0" | ./bin/ggen > graph.txt
(echo 100 8 0 0  60 100 25 4 1  0; grep '\-1$' graph.txt) | ./bin/sub_search > summary.txt
(echo 100 8 0 0  60 100 25 4 1  1; grep '\-1$' graph.txt) | ./bin/sub_search > details.txt
```

`summary.txt` only shows how close `sub_search` came to finding the desired subraph in each experiment, whereas `details.txt` also contains the subgraph's vertices for experiments where it was actually found (the edges are implied, since the subgraph is induced).

### Connecting ggen directly to sub_search

Alternatively, you can pipe the output of `ggen` directly into `sub_search` - **after filtering out everything but the adjacency matrix** - and either dump the results to standard output or redirect them to a file, like so (1-step approach):

```
(echo 100 8 0 0  60 100 25 4 1  0; echo "2 100 0 600 2  0 0  0" | ./bin/ggen | grep '\-1$') | ./bin/sub_search
(echo 100 8 0 0  60 100 25 4 1  0; echo "2 100 0 600 2  0 0  0" | ./bin/ggen | grep '\-1$') | ./bin/sub_search > summary.txt
(echo 100 8 0 0  60 100 25 4 1  1; echo "2 100 0 600 2  0 0  0" | ./bin/ggen | grep '\-1$') | ./bin/sub_search
(echo 100 8 0 0  60 100 25 4 1  1; echo "2 100 0 600 2  0 0  0" | ./bin/ggen | grep '\-1$') | ./bin/sub_search > details.txt
```

One benefit of the 1-step approach is that you avoid having to store the graph that `ggen` generated, which may in general be large, until `sub_search` actually finds some interesting subgraphs. Once you have the vertices you will generally want the edges, too, which you can then obtain by re-running `ggen` with the same arguments as before and redirecting the output to a file. The generated graph won't change, since the output of `ggen` is deterministic for a fixed random seed.

### Using sub_search as an approximation algorithm

Finding an exact match for the specified edge count can be difficult. Depending on the use case, you may also be interested in subgraphs which are a few edges off. 

To include matches which are at most n edges off in the `sub_search` output (n >= 0), set the `show_cols` flag (the last input argument) to n+1: `1` means show exact matches only, `2` means include graphs off by at most 1 edge, `3` means include graphs off by at most 2 edges, and so on. Setting `show_cols` to `0` supresses vertex output altogether.

To see this in action, compare the output of the following commands:

```
echo "2 100 0 600 2  0 0  0" | ./bin/ggen > graph.txt
(echo 100 8 0 0  60 100 25 4 1  0; grep '\-1$' graph.txt) | ./bin/sub_search > summary.txt
(echo 100 8 0 0  60 100 25 4 1  1; grep '\-1$' graph.txt) | ./bin/sub_search > details_exact_only.txt
(echo 100 8 0 0  60 100 25 4 1  2; grep '\-1$' graph.txt) | ./bin/sub_search > details_max_1_edge_off.txt
(echo 100 8 0 0  60 100 25 4 1  3; grep '\-1$' graph.txt) | ./bin/sub_search > details_max_2_edges_off.txt
```
