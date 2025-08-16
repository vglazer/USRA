#! /usr/bin/env bash

# Run the given generator utility to produce random graphs on disk in accordance with
# the specified input file 
# 
# Arguments:
#   generator       - path to the generator utility
#   input_file      - arguments to pass to the generator; what to name each output file 
#   base_graphs_dir - top-level directory for generated graphs, will contain several kinds
#   kind            - a tag to diffentiate one kind of graphs from another, e.g. "weighted"
#   pipe_args       - true if args should be piped into the generator, false if passed to it
# 
# Outputs:
#   Returns 0 if generator succeeded, 1 otherwise (if the generator is missing, say). Writes
#   graph files to the specified directory as a side-effect
function generate_graphs {
    local generator="$1"
    local input_file="$2"
    local base_graphs_dir="$3"
    local kind="$4"
    local pipe_args="$5"

    local funcname="${FUNCNAME[0]}"

    local binary
    binary=$(basename "${generator}")

    if [[ -f "${generator}" ]]; then 
        local graphs_dir
        graphs_dir="${base_graphs_dir}/${kind}"
        mkdir -p "${graphs_dir}"

        local counter='0'
        while read -r line; do
            counter=$((counter + 1))

            # skip header
            if [[ "${counter}" == '1' ]]; then
                continue
            fi

            # collapse multiple spaces to a single space; this too complex for ${variable//search/replace}
            local munged_line
            # shellcheck disable=SC2001
            munged_line=$(echo "${line}" | sed 's/ \+/ /gp')

            # the last token is the output file. everything else is a generator argument
            local args
            args=$(echo "${munged_line}" | awk '{ $NF=""; print $0 }')
            
            local output_file
            output_file=$(echo "${munged_line}" | awk '{ print $NF }')

            local generator_retval
            if [[ "${pipe_args}" == 'true' ]]; then
                echo "${args}" | "${generator}" > "${graphs_dir}/${output_file}"
            else
                # NB: args is deliberately left unqouted, since expansion is what we want in this case
                # shellcheck disable=SC2086
                "${generator}" ${args} > "${graphs_dir}/${output_file}"
            fi

            generator_retval="$?"
            if [[ "${generator_retval}" != '0' ]]; then
                echo "${funcname}: ${binary} failed with error code ${generator_retval}" >&2
                return "${generator_retval}"
            fi
        done <"${input_file}"

        return 0
    else
        echo "${funcname}: ${binary} not found. try running make ${binary}" >&2
        return 1
    fi
}

# Main driver
function main {
    scriptname=$(basename "$0")

    # the top-level repo directory is two levels up from the etc subdirectory 
    repo_dir=$(dirname "$(dirname "$(realpath "$0")")")
    bin_dir="${repo_dir}/bin"
    etc_dir="${repo_dir}/etc"
    base_graphs_dir="${repo_dir}/graphs"

    if [[ $# != 0 ]]; then
        echo "${scriptname} takes no arguments"
        exit 1
    fi

    generate_graphs "${bin_dir}/ggen" "${etc_dir}/ggen_inputs.txt" \
        "${base_graphs_dir}" 'unweighted' 'true'
    ggen_res="$?"

    generate_graphs "${bin_dir}/wggen" "${etc_dir}/wggen_inputs.txt" \
        "${base_graphs_dir}" 'weighted' 'false'
    wggen_res="$?"

    # return 0 if all generator commands succeeded, failure count otherwise
    retval=$((ggen_res + wggen_res))
    exit "${retval}"
}

main "$@"
