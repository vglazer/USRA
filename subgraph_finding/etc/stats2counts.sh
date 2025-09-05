#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")
if (( $# != 1 )); then
  cat >&2 <<EOF
Usage: $script_name stats_file

Arguments:  
  stats_file  Path to file containing stats. Filename must match stats_*.txt

EOF
  exit 1
fi

stats_path=$1
stats_dir=$(dirname "$stats_path")
stats_file=$(basename "$stats_path")
if [[ $stats_file =~ ^stats_(.+).txt$ ]]; then
    counts_file="counts_${BASH_REMATCH[1]}.csv"
    counts_path="$stats_dir/$counts_file"
else
    echo "$script_name: expected stats_file to match stats_*.txt, got $stats_file" >&2
    exit 1
fi

nedges=$(grep 'E =' "$stats_path" | cut -d',' -f 2 | cut -d'=' -f 2 | tr -d ' ')
echo "$nedges"

cat "$stats_path" | grep ':' | tr -s ' ' | sed 's/ : /,/g' | tr ' ' '\n' | grep . > "$counts_path"
echo "$counts_path"
