#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")
default_sep=150
default_width=0.05
default_shape="point"
default_layout="sfdp"
default_splines="false"
if (( $# < 1 || $# > 6 )); then
  cat >&2 <<EOF
Usage: $script_name edges_file sep width shape layout splines

Arguments:  
  edges_file  Path to file containing graph edges. Filename must match edges_*.csv
  sep         Graphviz sep parameter (150, 5), default: $default_sep
  width       Graphviz node width (and height) parameter (0.05, 0.5), default: $default_width
  shape       Graphviz node shape parameter (point, circle), default: $default_shape
  layout      Graphviz layout engine (sfdp, neato), default: $default_layout
  splines     Graphviz splines parameter (false, true, curved), default: $default_splines

EOF
  exit 1
fi

edges_path=$1
edges_dir=$(dirname "$edges_path")
edges_file=$(basename "$edges_path")
layout=${5:-"$default_layout"}
if [[ $edges_file =~ ^edges_(.+).csv$ ]]; then
    graphviz_file="${layout}_${BASH_REMATCH[1]}.dot"
    graphviz_path="$edges_dir/$graphviz_file"
else
    echo "$script_name: expected edges_file to match edges_*.csv, got $edges_file" >&2
    exit 1
fi

sep=${2:-"$default_sep"}
width=${3:-"$default_width"}
shape=${4:-"$default_shape"}
splines=${6:-"$default_splines"}
awk_script='
  BEGIN {
    height=width

    print "graph G {\n" \
          "  layout=" layout ";\n" \
          "  sep=\"+" sep "," sep "\";\n" \
          "  overlap=false;\n" \
          "  splines=" splines ";\n" \
          "  node [shape=" shape ", width=" width ", height=" height "];\n"
  }

  { 
    # undirected graph
    print "  " $1 " -- " $2 ";"
    
    nedges++
  }

  END {
    print "}"

    print nedges > "/dev/stderr"
  }'

cat "$edges_path" | awk -F',' -v shape="$shape" -v layout="$layout" -v sep="$sep" -v width="$width" -v splines="$splines" "$awk_script" > "$graphviz_path"
echo "$graphviz_path"
