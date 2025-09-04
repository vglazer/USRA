#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")
default_sep=150
default_width=0.05
default_shape="point"
default_layout="sfdp"
if (( $# < 1 || $# > 5 )); then
  cat >&2 <<EOF
Usage: $script_name edges_file sep width shape layout

Arguments:  
  edges_file  Path to file containing graph edges. Filename must match edges_*.txt
  sep         Graphviz sep parameter (150, 5), default: $default_sep
  width       Graphviz node width (and height) parameter (0.05, 0.5), default: $default_width
  shape       Graphviz node shape parameter (point, circle), default: $default_shape
  layout      Graphviz layout engine (sfdp, neato), default: $default_layout

EOF
  exit 1
fi

edges_path=$1
edges_dir=$(dirname "$edges_path")
edges_file=$(basename "$edges_path")
layout=${5:-"$default_layout"}
if [[ $edges_file =~ ^edges_(.+).txt$ ]]; then
    graphviz_file="${layout}_${BASH_REMATCH[1]}.dot"
    graphviz_path="$edges_dir/$graphviz_file"
else
    echo "$script_name: expected edges_file to match edges_*.txt, got $edges_file" >&2
    exit 1
fi
sep=${2:-"$default_sep"}
width=${3:-"$default_width"}
shape=${4:-"$default_shape"}
awk_script='
  BEGIN {
    height=width;
    print "graph G {"; 
    print "  layout=" layout ";"
    print "  sep=\"+" sep "," sep "\";"
    print "  overlap=false;"
    print "  splines=true;"
    print "  node [shape=" shape ", width=" width ", height=" height "];"
    print

    edge=0;
  }

  { 
    # undirected graph
    print "  " $1 " -- " $2 ";";
    
    edge++;
  }

  END { 
    print "}";

    print edge > "/dev/stderr" 
  }
'
cat "$edges_path" | awk -F',' -v shape="$shape" -v layout="$layout" -v sep="$sep" -v width="$width" "$awk_script" > "$graphviz_path"
echo "$graphviz_path"
