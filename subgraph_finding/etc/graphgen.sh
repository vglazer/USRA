#! /usr/bin/env bash

scriptname=$(basename $0)

# the top-level repo directory is two levels up from the etc subdirectory 
repo_dir=$(dirname $(dirname $(realpath $0)))
bin_dir=$repo_dir/bin
etc_dir=$repo_dir/etc
base_graphs_dir=$repo_dir/graphs

# generate sample unweighted random graphs using ggen
if [ -f $bin_dir/ggen ]; then 
    graphs_dir_unweighted=$base_graphs_dir/unweighted
    mkdir -p $graphs_dir_unweighted

    while read line; do
        inputs=`echo "$line" | awk '{ $NF=""; print $0 }'`
        filename=`echo "$line" | awk '{ print $NF }'`
        echo $inputs | $bin_dir/ggen > $graphs_dir_unweighted/$filename
    done <$etc_dir/ggen_inputs.txt 
else
    echo "$scriptname: $bin_dir/ggen does not exist. try running make ggen" >&2
fi

# generate sample weighted random graphs using wggen
if [ -f $bin_dir/wggen ]; then 
    graphs_dir_weighted=$base_graphs_dir/weighted
    mkdir -p $graphs_dir_weighted
    while read line; do
        inputs=`echo "$line" | awk '{ $NF=""; print $0 }'`
        filename=`echo "$line" | awk '{ print $NF }'`
        $bin_dir/wggen $inputs > $graphs_dir_weighted/$filename
    done <$etc_dir/wggen_inputs.txt     
else
    echo "$scriptname: $bin_dir/wggen does not exist. try running make wggen" >&2
fi

exit 0
