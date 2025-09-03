#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")
if (( $# != 1 )); then
  cat >&2 <<EOF
Usage: $script_name edges_file

Arguments:  
  edges_file  Path to file containing graph edges. Filename must match edges_*.txt

EOF
  exit 1
fi

edges_path=$1
edges_dir=$(dirname "$edges_path")
edges_file=$(basename "$edges_path")
if [[ $edges_file =~ ^edges_(.+).txt$ ]]; then
    graphviz_file="graphviz_${BASH_REMATCH[1]}.dot"
    graphviz_path="$edges_dir/$graphviz_file"
else
    echo "$script_name: expected edges_file to match edges_*.txt, got $edges_file" >&2
    exit 1
fi

awk_script='
  BEGIN { print "graph G {" }

  # undirected graph
  { print "  " $1 " -- " $2 ";" }

  END { print "}" }
'
cat "$edges_path" | awk -F',' -v graphviz_path="$graphviz_path" "$awk_script" > "$graphviz_path"
echo "$graphviz_path"