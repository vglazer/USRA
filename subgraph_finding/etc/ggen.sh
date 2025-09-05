#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")
default_seed=1
default_compl=0
default_graph_dir=$(pwd)

graph_type_to_str[2]="Exponential"
graph_type_to_str[3]="Power"
graph_type_to_str[4]="Geometric"

if (( $# < 3 || $# > 6 )); then
  cat >&2 <<EOF
Usage: $script_name graph_type v density [seed] [compl] [graph_dir]

Arguments:  
  graph_type   Type of graph to generate (2: ${graph_type_to_str[2]} , 3: ${graph_type_to_str[3]}, 4: ${graph_type_to_str[4]})
  v            Number of vertices
  density      Graph density (0 <= density <= 1000)
  seed         Optional random seed (a positive integer), default: $default_seed
  compl        Optionally take the complement of the graph (0 or 1), default: $default_compl
  graph_dir    Directory to write graphs and stats to, default: current working directory

Examples:
  exponential, 100  vertices,  density 600, seed $default_seed,  don't complement: $script_name 2 100  600
  exponential, 100  vertices,  density 600, seed 2,  don't complement: $script_name 2 100  600 2
  exponential, 100  vertices,  density 600, seed 2,   take complement: $script_name 2 100  600 2  1
  power,       2500 vertices,  density 200, seed 52,  take complement: $script_name 3 2500 200 52 1 graphs
  geometric,   790  vertices,  density 150, seed 1,  don't complement: $script_name 4 790  150 1

Graphs are saved to graph_dir as ggen_type_v_density_seed_compl.txt

EOF
  exit 1
fi

script_dir=$(dirname "$(realpath "$0")")
repo_dir=$(dirname "$script_dir")
ggen_binary="$repo_dir/bin/ggen"
if [[ ! -f "$ggen_binary" ]]; then
  echo "$script_name: ggen binary not found" >&2
  echo "make -C $repo_dir ggen" >&2
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

graph_dir=${6:-"$default_graph_dir"}
if [[ ! -d "$graph_dir" ]]; then
  echo "$script_name: graph directory $graph_dir does not exist" >&2
  echo "mkdir -p $graph_dir" >&2
  exit 1
fi

signature="$graph_type-$v-$density-$seed-$compl"
graph_file="graph_$signature.txt"
graph_path="$graph_dir/$graph_file"

graph_type_to_string[2]="one"
awk_script_degrees='
  {
    vertex = NR-1
    for (i=1; i<=NF; i++) {
      degrees[vertex]++
      degrees[$i]++
    }
  }

  END {
    for (vertex in degrees) {
      print degrees[vertex]
    }
  }'

hist_file="hist_$signature.pdf"
hist_path="$graph_dir/$hist_file"
p_edge=$(echo "scale=2; $density / 1000" | bc -l)
gnuplot_script="
set terminal pdf monochrome;
set title '${graph_type_to_str[$graph_type]} (|V| = $v, p = $p_edge); seed: $seed, compl: $compl';
set xlabel 'Degree';
set ylabel 'Frequency';
set output '$hist_path';
plot '-' using 1:(1.0) smooth freq with boxes notitle'
"

# split ggen output into two separate files, one for the stats and one for the graph itself
stats_file="stats_$signature.txt"
stats_path="$graph_dir/$stats_file"
echo "$graph_type $v $num_sets $density $seed $num_fixed $fixed_type $compl" | $ggen_binary | tee >(grep "\-1$" > "$graph_path") | tee >(grep -v "\-1$" > "$stats_path") | grep "\-1$" | sed 's/-1//g' | awk "$awk_script_degrees" | gnuplot -e "$gnuplot_script"

nedges=$(grep 'E =' "$stats_path" | cut -d',' -f 2 | cut -d'=' -f 2 | tr -d ' ')
echo "$nedges"
echo "$stats_path"
echo "$graph_path"
