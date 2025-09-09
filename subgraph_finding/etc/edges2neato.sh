#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")
if (( $# != 1 )); then
  cat >&2 <<EOF
Usage: $script_name edges_file 

Arguments:  
  edges_file  Path to file containing graph edges. Filename must match edges_*.csv

EOF
  exit 1
fi

edges_path=$1

# these settings work well for "small" graphs
sep=5
width=0.5
shape="circle"
layout="neato"
splines="true"

script_dir=$(dirname "$(realpath "$0")")
command="$script_dir/edges2dot.sh $edges_path $sep $width $shape $layout $splines"
$command
