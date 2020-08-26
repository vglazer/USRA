#! /usr/bin/env bash

scriptname=$(basename "$0")

# the top-level repo directory is two levels up from the etc subdirectory 
repo_dir=$(dirname "$(dirname "$(realpath "$0")")")
bin_dir="${repo_dir}/bin"
etc_dir="${repo_dir}/etc"
base_graphs_dir="${repo_dir}/graphs"

if [[ $# -ne 0 ]]; then
    echo "${scriptname} takes no arguments"
    exit 1
fi

function generate_graphs {
    local generator="$1"
    local input_file="$2"
    local base_graphs_dir="$3"
    local kind="$4"
    local pipe_args="$5"

    if [[ -f "${generator}" ]]; then 
        graphs_dir="${base_graphs_dir}/${kind}"
        mkdir -p "${graphs_dir}"

        while read -r line; do
            # the last token is the output file. everything else is a generator argument
            args=$(echo "${line}" | awk '{ $NF=""; print $0 }')
            output_file=$(echo "${line}" | awk '{ print $NF }')

            if [[ "${pipe_args}" = 'true' ]]; then
                echo "${args}" | ${generator} > "${graphs_dir}/${output_file}"
            else 
                ${generator} "${args}" > "${graphs_dir}/${output_file}"
            fi
        done <"${input_file}"

        return 0
    else
        local funcname="${FUNCNAME[0]}"

        local binary
        binary=$(basename "${generator}")

        echo "${funcname}: ${binary} not found. try running make ${binary}" >&2

        return 1
    fi
}

generate_graphs "${bin_dir}/ggen" "${etc_dir}/ggen_inputs.txt" \
    "${base_graphs_dir}" 'unweighted' 'true'
ggen_res="$?"

generate_graphs "${bin_dir}/wggen" "${etc_dir}/wggen_inputs.txt" \
    "${base_graphs_dir}" 'weighted' 'false'
wggen_res="$?"

# return 0 if all generator commands succeeded, failure count otherwise
retval=$((ggen_res + wggen_res))
exit "${retval}"
