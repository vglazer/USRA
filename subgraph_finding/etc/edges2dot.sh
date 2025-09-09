#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")

default_layout="sfdp"
default_sep=150
default_splines="false"
default_shape="point"
default_width=0.05
if (( $# < 1 || $# > 6 )); then
  cat >&2 <<EOF
Usage: $script_name edges_file layout sep splines shape width

Arguments:  
  edges_file  Path to file containing graph edges. Filename must match edges_*.csv
  layout      Graphviz layout engine (sfdp, neato), default: $default_layout
  sep         Graphviz sep parameter (150, 5), default: $default_sep
  splines     Graphviz splines parameter (false, true, curved), default: $default_splines
  shape       Graphviz node shape parameter (point, circle), default: $default_shape
  width       Graphviz node width (and height) parameter (0.05, 0.5), default: $default_width

EOF
  exit 1
fi

edges_path=$1
edges_dir=$(dirname "$edges_path")
edges_file=$(basename "$edges_path")
layout=${2:-"$default_layout"}
if [[ $edges_file =~ ^edges_(.+).csv$ ]]; then
    graphviz_file="${layout}_${BASH_REMATCH[1]}.dot"
    graphviz_path="$edges_dir/$graphviz_file"
else
    echo "$script_name: expected edges_file to match edges_*.csv, got $edges_file" >&2
    exit 1
fi

sep=${3:-"$default_sep"}
splines=${4:-"$default_splines"}
shape=${5:-"$default_shape"}
width=${6:-"$default_width"}
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

cat "$edges_path" | awk -F',' -v layout="$layout" -v sep="$sep" -v splines="$splines" -v shape="$shape" -v width="$width" "$awk_script" > "$graphviz_path"
echo "$graphviz_path"
