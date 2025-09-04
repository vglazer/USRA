#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")
if (( $# != 1 )); then
  cat >&2 <<EOF
Usage: $script_name graphviz_file

Arguments:  
  graphviz_file  Path to file containing Graphviz graph description. Filename must match *.dot

EOF
  exit 1
fi

graphviz_path=$1
graphviz_dir=$(dirname "$graphviz_path")
graphviz_file=$(basename "$graphviz_path")
if [[ $graphviz_file =~ ^(.+).dot$ ]]; then
    name="${BASH_REMATCH[1]}"
    pdf_file="${name}.pdf"
    pdf_path="$graphviz_dir/$pdf_file"
else
    echo "$script_name: dot_file must match *.dot, got $graphviz_file" >&2
    exit 1
fi

dot -Tpdf "$graphviz_path" -o "$pdf_path"
echo "$pdf_path"
