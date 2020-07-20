# Reports
The following reports describe the purpose of each program as well as 
outlining the data structures and algorithms used. Sample usage is also
provided.

Program                                                                                          | Description
-------------------------------------------------------------------------------------------------|------------
[`sub_search`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/sub_search.md)   | Find induced subgraphs with the specified edge count in undirected, unweighted graphs
[`asub_search`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/asub_search.md) | `sub_search` with "limited aspiration"
[`wsub_search`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/wsub_search.md) | `sub_search` with weights
[`reg_search`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/reg_search.md)   | Find regular induced subgraphs with the specified degree in undirected, unweighted graphs
[`ereg_search`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/ereg_search.md) | `reg_search` with `sub_search` for the initial guess
[`ggen`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/ggen.md)               | Generate and manipulate undirected, unweighted graphs
[`wggen`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/wggen.md)             | `ggen` with weights, but no manipulation
