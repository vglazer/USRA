#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")
if (( $# < 1 )); then
  cat >&2 <<EOF
Usage: $script_name graph_file

Arguments:  
  graph_file  File containing graph to check. Must be named graph_foo.txt

EOF
  exit 1
fi

graph_file=$1
if [[ $graph_file =~ ^graph_(.+).txt$ ]]; then
    edges_file="edges_${BASH_REMATCH[1]}.txt"
else
    echo "$script_name: expected graph_file to match graph_foo.txt, got $graph_file" >&2
    exit 1
fi

awk_script='{
nedges += NF;
vertex = NR-1;
print vertex ":" $0";\n" vertex " -> " NF; 

for (i = 1; i <= NF; i++) 
  print "{" vertex "," $i "}" >> edges_file 
}

END {print nedges}'
cat "$graph_file" | sed 's/-1//g' | awk -v edges_file="$edges_file" "$awk_script"