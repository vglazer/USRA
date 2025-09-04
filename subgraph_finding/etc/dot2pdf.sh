#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")
if (( $# != 1 )); then
  cat >&2 <<EOF
Usage: $script_name graphviz_file

Arguments:  
  graphviz_file  Path to file containing Graphviz graph description. Filename must match {sfdp|neato}*.dot

EOF
  exit 1
fi

graphviz_path=$1
graphviz_dir=$(dirname "$graphviz_path")
graphviz_file=$(basename "$graphviz_path")
if [[ $graphviz_file =~ ^(sfdp|neato)_(.+).dot$ ]]; then
    layout="${BASH_REMATCH[1]}"
    signature="${BASH_REMATCH[2]}"
    pdf_file="${layout}_${signature}.pdf"
    pdf_path="$graphviz_dir/$pdf_file"
else
    echo "$script_name: dot_file must match (sfdp|neato)*.dot, got $graphviz_file" >&2
    exit 1
fi

"$layout" -Tpdf "$graphviz_path" -o "$pdf_path"
echo "$pdf_path"
