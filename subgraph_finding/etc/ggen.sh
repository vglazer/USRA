#! /usr/bin/env bash

set -euo pipefail 
set -x

script_name=$(basename "$0")
default_seed=1
default_compl=0
unweighted_subdir="graphs/unweighted"
if (( $# < 3 )); then
    cat >&2 <<EOF
Usage: $script_name graph_type v density [seed] [compl]

Arguments:  
  graph_type   Type of graph to generate (2: exponential, 3: power, 4: geometric)
  v            Number of vertices
  density      Graph density (0 <= density <= 1000)
  seed         Optional random seed (a positive integer), default: $default_seed
  compl        Optionally take the complement of the graph (0 or 1), default: $default_compl

Examples:
  exponenital, 100  vertices,  density 600, seed $default_seed,  don't complement: $script_name 2 100  600
  exponenital, 100  vertices,  density 600, seed 2,  don't complement: $script_name 2 100  600 2
  exponenital, 100  vertices,  density 600, seed 2,  take complement:  $script_name 2 100  600 2  1
  power,       2500 vertices,  density 200, seed 52, take complement:  $script_name 3 2500 200 52 1
  geometric,   790  vertices,  density 150, seed 1,  don't complement: $script_name 4 790  150 1

Graphs are saved to $unweighted_subdir as ggen_type_v_density_seed_compl.txt

EOF
    exit 1
fi

# num_sets, num_fixed and fixed_type are set to 0 since ggen.sh does not support the relevant ggen functionality
graph_type=$1
v=$2
num_sets=0
density=$3
seed=${4:-"$default_seed"}
num_fixed=0
fixed_type=0
compl=${5:-"$default_compl"}

script_dir=$(dirname "$(realpath "$0")")
repo_dir=$(dirname "$script_dir")
ggen_binary="$repo_dir/bin/ggen"

graph_dir="$repo_dir/$unweighted_subdir"
if [[ ! -d "$graph_dir" ]]; then
    mkdir -p "$graph_dir"
fi
graph_file="ggen_${graph_type}_${v}_${density}_${seed}_${compl}.txt"
graph_path="$graph_dir/$graph_file"

# save only the graph itself, which is specified as '-1'-terminated adjanency lists, to disk
echo "$graph_type $v $num_sets $density $seed $num_fixed $fixed_type $compl" | $ggen_binary | tee >(grep "\-1$" > "$graph_path") | grep -v "\-1$"