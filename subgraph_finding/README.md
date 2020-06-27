# Overview
Some 
[combinatorial designs](https://en.wikipedia.org/wiki/Combinatorial_design) 
lack algebraic structure and require constructive proofs
to settle existence. The problem can be reduced to finding [induced
subgraphs](https://en.wikipedia.org/wiki/Induced_subgraph) with a 
prescribed edge count in various flavors of graphs. We provide a suite of 
efficient 
[stochastic local search](https://www.researchgate.net/publication/283825846_Stochastic_Local_Search_Algorithms_An_Overview) 
algorithms for doing so, based on 
[Tabu search](https://en.wikipedia.org/wiki/Tabu_search) 
and [implemented in C](https://github.com/vglazer/USRA/tree/master/subgraph_finding/src). 
See [report](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/README.md) for details
