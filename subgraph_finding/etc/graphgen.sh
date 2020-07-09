#! /usr/bin/env bash

# the top-level repo directory is two levels up from the etc subdirectory 
repo_dir=$(dirname $(dirname $(realpath $0)))
bin_dir=$repo_dir/bin
base_graphs_dir=$repo_dir/graphs

# generate sample unweighted random graphs using ggen
if [ -f $bin_dir/ggen ]; then 
    graphs_dir_unweighted=$base_graphs_dir/unweighted
    mkdir -p $graphs_dir_unweighted
    echo "2 100 0 600 2 0 0 0" | $bin_dir/ggen > $graphs_dir_unweighted/exponential_100.txt
    echo "3 2500 0 200 52 0 0 0" | $bin_dir/ggen > $graphs_dir_unweighted/power_2500.txt
    echo "3 2500 0 200 52 0 0 1" | $bin_dir/ggen > $graphs_dir_unweighted/power_2500_complement.txt
    echo "4 790 0 150 1 0 0 0" | $bin_dir/ggen > $graphs_dir_unweighted/geometric_790.txt
else
    echo "$bin_dir/ggen does not exist. try running make ggen"
fi

# generate sample weighted random graphs using wggen
if [ -f $bin_dir/wggen ]; then 
    graphs_dir_weighted=$base_graphs_dir/weighted
    mkdir -p $graphs_dir_weighted
    $bin_dir/wggen 200 65 1 > $graphs_dir_weighted/exponential_200.txt
    $bin_dir/wggen 1500 300 72 > $graphs_dir_weighted/exponential_1500.txt
else
    echo "$bin_dir/wggen does not exist. try running make wggen"
fi
