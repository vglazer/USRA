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
layout="neato"
sep=5
splines="true"
shape="circle"
width=0.5

script_dir=$(dirname "$(realpath "$0")")
command="$script_dir/edges2dot.sh $edges_path $layout $sep $splines $shape $width"
$command
