#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")
if (( $# < 1 )); then
  cat >&2 <<EOF
Usage: $script_name graph_file

Arguments:  
  graph_file  Path to file containing graph to check. Filename must match graph_*.txt

EOF
  exit 1
fi

graph_path=$1
graph_dir=$(dirname "$graph_path")
graph_file=$(basename "$graph_path")
if [[ $graph_file =~ ^graph_(.+).txt$ ]]; then
    edges_file="edges_${BASH_REMATCH[1]}.txt"
    edges_path="$graph_dir/$edges_file"
else
    echo "$script_name: expected graph_file to match graph_*.txt, got $graph_file" >&2
    exit 1
fi

# needed because we are appending edges
rm -f "$edges_path"

awk_script='{
  nedges += NF;
  vertex = NR-1;
  print vertex " : " NF; 

  for (i = 1; i <= NF; i++) 
    print vertex "," $i >> edges_path 
  }

  END {print nedges}'
cat "$graph_path" | sed 's/-1//g' | awk -v edges_path="$edges_path" "$awk_script"
echo "$edges_path"