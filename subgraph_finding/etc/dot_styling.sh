#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")
if (( $# != 5 )); then
  cat >&2 <<EOF
Usage: $script_name dot_file sep width shape layout

Arguments:  
  dot_file  Path to file graph in dot format with no styling. Filename must match no_styling_*.dot
  sep       Graphviz sep parameter (150, 5)
  width     Graphviz node width (and height) parameter (0.05, 0.5)
  shape     Graphviz node shape parameter (point, circle)
  layout    Graphviz layout engine (sfdp, neato)

EOF
  exit 1
fi

dot_path=$1
dot_dir=$(dirname "$dot_path")
dot_file=$(basename "$dot_path")
layout=$5
if [[ $dot_file =~ ^no_styling_(.+).dot$ ]]; then
    graphviz_file="${layout}_${BASH_REMATCH[1]}.dot"
    graphviz_path="$dot_dir/$graphviz_file"
else
    echo "$script_name: expected edges_file to match no_styling_*.dot, got $dot_file" >&2
    exit 1
fi

sep=$2
width=$3
shape=$4
cat << EOF > "$graphviz_path"
graph G {
  layout=$layout;
  sep="+$sep,$sep";
  overlap=false;
  splines=true;
  node [shape=$shape, width=$width, height=$width];

EOF
cat "$dot_path" | grep '\-\-' >> "$graphviz_path"
echo "}" >> "$graphviz_path"

echo "$graphviz_path"
