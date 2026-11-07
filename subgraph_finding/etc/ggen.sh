#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

graph_type_to_str[2]="exponential"
graph_type_to_str[3]="power"
graph_type_to_str[4]="geometric"

script_name=$(basename "$0")
default_seed=1
default_compl=0
if (( $# < 3 || $# > 6 )); then
  cat >&2 <<EOF
Usage: $script_name graph_type v density [seed] [compl] [graph_dir]

Arguments:  
  graph_type   Type of graph to generate (2: ${graph_type_to_str[2]}, 3: ${graph_type_to_str[3]}, 4: ${graph_type_to_str[4]})
  v            Number of vertices
  density      Graph density (0 <= density <= 1000, density 500 means that 50% of the edges are present)
  seed         Optional random seed (a positive integer), default: $default_seed
  compl        Optional complementation flag (0 or 1), default: $default_compl
  graph_dir    Optional directory to write graphs and stats to, default: current working directory

Examples:
  exponential, 100  vertices,  density 600, seed $default_seed,  don't complement: $script_name 2 100  600
  exponential, 100  vertices,  density 600, seed 2,  don't complement: $script_name 2 100  600 2
  exponential, 100  vertices,  density 600, seed 2,  take complement:  $script_name 2 100  600 2  1
  power,       2500 vertices,  density 200, seed 42, take complement:  $script_name 3 2500 200 42 1 graphs
  geometric,   790  vertices,  density 150, seed 42, don't complement: $script_name 4 790  150 42

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

default_graph_dir=$(pwd)
graph_dir=${6:-"$default_graph_dir"}
if [[ ! -d "$graph_dir" ]]; then
  echo "$script_name: graph directory $graph_dir does not exist" >&2
  echo "mkdir -p $graph_dir" >&2
  exit 1
fi

graph_type=$1
v=$2
density=$3
seed=${4:-"$default_seed"}
compl=${5:-"$default_compl"}

die() {
  echo "$script_name: $*" >&2
  exit 1
}
[[ $graph_type =~ ^[234]$ ]] || die "graph_type must be 2, 3 or 4, got '$graph_type'"
[[ $v =~ ^[1-9][0-9]*$ ]] || die "v must be a positive integer, got '$v'"
[[ $density =~ ^[0-9]+$ ]] && (( density <= 1000 )) || die "density must be an integer between 0 and 1000, got '$density'"
[[ $seed =~ ^[1-9][0-9]*$ ]] || die "seed must be a positive integer, got '$seed'"
[[ $compl =~ ^[01]$ ]] || die "compl must be 0 or 1, got '$compl'"
signature="$graph_type-$v-$density-$seed-$compl"

hist_file="hist_$signature.pdf"
hist_path="$graph_dir/$hist_file"

graph_type_str="${graph_type_to_str[$graph_type]}"
xlabel='degree'
ylabel='frequency'
gnuplot_script="
set terminal pdf monochrome;
set title '$graph_type_str (v = $v, density = $density); seed: $seed, compl: $compl';
set xlabel '$xlabel';
set ylabel '$ylabel';
set output '$hist_path';
plot '-' using 1:(1.0) smooth freq with boxes notitle
"

graph_file="graph_$signature.txt"
graph_path="$graph_dir/$graph_file"

stats_file="stats_$signature.txt"
stats_path="$graph_dir/$stats_file"

plots_file="plot_$signature.pdf"
plots_path="$graph_dir/$plots_file"

dot_file="graph_$signature.dot"
dot_path="$graph_dir/$dot_file"

# reads the '-1'-stripped adjacency list; writes the graph in DOT format to dot_path
# and one degree per vertex to stdout
awk_script='
  BEGIN {
    for (i = 0; i < v; i++) {
      degrees[i] = 0
    }

    print "graph G {" > dot_path

    if (large_graph) {
      print "  layout=sfdp;\n" \
            "  sep=\"+150,150\";\n" \
            "  overlap=false;\n" \
            "  splines=false;\n" \
            "  node [shape=point, width=0.05, height=0.05];\n" > dot_path
    }
  }
  
  {
    vertex = NR-1
    for (i = 1; i <= NF; i++) {
      degrees[vertex]++
      degrees[$i]++

      # undirected graph
      print "  " vertex " -- " $i ";" > dot_path
    }
  }

  END {
    for (vertex in degrees) {
      degree = degrees[vertex]
      print degree

      if (!degree) {
        print "  " vertex ";" > dot_path
      }
    }

    print "}" > dot_path
  }'

# an arbitrary threshold selected based on what "looks reasonable" on my machine
if (( v > 20 )); then
  large_graph=1
else
  large_graph=0
fi

# run ggen once, saving its raw output, then derive every output file from it in sequence,
# so that each file is complete before the next step (or the caller) reads it.
# num_sets, num_fixed and fixed_type are set to 0 since ggen.sh does not support the relevant ggen functionality
num_sets=0
num_fixed=0
fixed_type=0
raw_path=$(mktemp)
trap 'rm -f "$raw_path"' EXIT
echo "$graph_type $v $num_sets $density $seed $num_fixed $fixed_type $compl" | "$ggen_binary" > "$raw_path"

grep -- '-1$' "$raw_path" > "$graph_path"
grep -v -- '-1$' "$raw_path" > "$stats_path"

degrees=$(sed 's/-1//g' "$graph_path" | awk -v v="$v" -v large_graph="$large_graph" -v dot_path="$dot_path" "$awk_script")
gnuplot -e "$gnuplot_script" <<< "$degrees"
dot -Tpdf -o "$plots_path" "$dot_path"

nedges=$(grep 'E =' "$stats_path" | cut -d',' -f 2 | cut -d'=' -f 2 | tr -d ' ')
echo "$nedges"
echo "$stats_path"
echo "$graph_path"
echo "$dot_path"
echo "$plots_path"
echo "$hist_path"
