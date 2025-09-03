#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")
if (( $# != 1 )); then
  cat >&2 <<EOF
Usage: $script_name graphviz_file

Arguments:  
  graphviz_file  Path to file containing Graphviz graph description. Filename must match foo.dot

EOF
  exit 1
fi

graphviz_path=$1
graphviz_dir=$(dirname "$graphviz_path")
graphviz_file=$(basename "$graphviz_path")
if [[ $graphviz_file =~ ^(.+).dot$ ]]; then
    pdf_file="${BASH_REMATCH[1]}.pdf"
    pdf_path="$graphviz_dir/$pdf_file"
else
    echo "$script_name: expected dot_file to match foo.dot, got $graphviz_file" >&2
    exit 1
fi

sfdp -Tpdf "$graphviz_path" -o "$pdf_path"
echo "$pdf_path"
