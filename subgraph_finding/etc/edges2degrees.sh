#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")

if (( $# != 1 )); then
  cat >&2 <<EOF
Usage: $script_name edges_file sep width shape layout

Arguments:  
  edges_file  Path to file containing graph edges. Filename must match edges_*.csv

EOF
  exit 1
fi

edges_path=$1
edges_dir=$(dirname "$edges_path")
edges_file=$(basename "$edges_path")
if [[ $edges_file =~ ^edges_(.+).csv$ ]]; then
    degrees_file="degrees_${BASH_REMATCH[1]}.csv"
    degrees_path="$edges_dir/$degrees_file"
else
    echo "$script_name: expected edges_file to match edges_*.csv, got $edges_file" >&2
    exit 1
fi

awk_script_degrees='{
  degrees[$1]++; 
  degrees[$2]++;
} 

END { 
  for (vertex in degrees) 
    print vertex "," degrees[vertex]
}'

cat "$edges_path" | awk -F ',' "$awk_script_degrees" | sort -t',' -k1,1n > "$degrees_path"

awk_script_counts='{
  count[$2]++;
} 

END {
  for (key in count)
    print key "," count[key]
}'

cat "$degrees_path" | awk -F ',' "$awk_script_counts" | sort -t',' -k1,1n
echo "$degrees_path"
