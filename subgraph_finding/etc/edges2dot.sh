#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")

default_layout="sfdp"
default_sep=150
default_splines="false"
default_shape="point"
default_width=0.05
if (( $# < 2 || $# > 7 )); then
  cat >&2 <<EOF
Usage: $script_name v edges_file [layout] [sep] [splines] [shape] [width]

Arguments:
  v           Number of vertices
  edges_file  Path to file containing graph edges. Filename must match edges_*.csv
  layout      Optional Graphviz layout engine (sfdp, neato), default: $default_layout
  sep         Optional Graphviz sep parameter (150, 5), default: $default_sep
  splines     Optional Graphviz splines parameter (false, true, curved), default: $default_splines
  shape       Optional Graphviz node shape parameter (point, circle), default: $default_shape
  width       Optional Graphviz node width (and height) parameter (0.05, 0.5), default: $default_width

EOF
  exit 1
fi

edges_path=$2
edges_dir=$(dirname "$edges_path")
edges_file=$(basename "$edges_path")
layout=${3:-"$default_layout"}
if [[ $edges_file =~ ^edges_(.+).csv$ ]]; then
    graphviz_file="${layout}_${BASH_REMATCH[1]}.dot"
    graphviz_path="$edges_dir/$graphviz_file"
else
    echo "$script_name: expected edges_file to match edges_*.csv, got $edges_file" >&2
    exit 1
fi

sep=${4:-"$default_sep"}
splines=${5:-"$default_splines"}
shape=${6:-"$default_shape"}
width=${7:-"$default_width"}
awk_script='
  BEGIN {
    for (i = 0; i < v; i++) {
      degrees[i] = 0
    }

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

    degrees[$1]++
    degrees[$2]++
    
    nedges++
  }

  END {
    for (vertex in degrees) {
      if (!degrees[vertex]) {
        print "  " vertex ";"
      }
    }

    print "}"

    if (nedges) {
      print nedges > "/dev/stderr"
    }
  }'

v=$1
cat "$edges_path" | awk -F',' -v v="$v" -v layout="$layout" -v sep="$sep" -v splines="$splines" -v shape="$shape" -v width="$width" "$awk_script" > "$graphviz_path"
echo "$graphviz_path"
