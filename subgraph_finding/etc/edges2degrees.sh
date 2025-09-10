#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")

if (( $# != 2 )); then
  cat >&2 <<EOF
Usage: $script_name v edges_file

Arguments:
  v           Number of vertices
  edges_file  Path to file containing graph edges. Filename must match edges_*.csv

EOF
  exit 1
fi

v=$1
edges_path=$2
edges_dir=$(dirname "$edges_path")
edges_file=$(basename "$edges_path")
if [[ $edges_file =~ ^edges_(.+).csv$ ]]; then
    signature="${BASH_REMATCH[1]}"
    degrees_file="degrees_$signature.csv"
    degrees_path="$edges_dir/$degrees_file"

    degrees_count_file="degree_counts_$signature.csv"
    degrees_count_path="$edges_dir/$degrees_count_file"
else
    echo "$script_name: expected edges_file to match edges_*.csv, got $edges_file" >&2
    exit 1
fi

awk_script_degrees='
BEGIN {
  for (i = 0; i < v; i++) {
    degrees[i] = 0
  }
}

{
  degrees[$1]++
  degrees[$2]++

  nedges++
} 

END {
  degree_sum=0
  for (vertex in degrees) {
    degree = degrees[vertex]
    degree_sum += degree
    
    print vertex "," degree
  }

  # degrees should sum to 2*|E|
  if (nedges) {
    print nedges > "/dev/stderr"
  }
  print degree_sum > "/dev/stderr"
}'

cat "$edges_path" | awk -F ',' -v v="$v" "$awk_script_degrees" | sort -t',' -k1,1n > "$degrees_path"

# compute degree counts by inverting the degrees hash
awk_script_counts='{
  counts[$2]++;
} 

END {
  for (degree in counts) {
    print degree "," counts[degree]
  }
}'

cat "$degrees_path" | awk -F ',' "$awk_script_counts" | sort -t',' -k1,1n > "$degrees_count_path"
echo "$degrees_path"
echo "$degrees_count_path"
