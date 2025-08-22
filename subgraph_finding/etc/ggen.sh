#! /usr/bin/env bash

function log_message {
    local malformed_args
    local func_name
    local message
    if (( $# != 2 )); then
        malformed_args=1
        func_name="${FUNCNAME[0]}"
        message="Error: arguments are <function_name> <message>"        
    else 
        malformed_args=0
        func_name="$1"
        message="$2"
    fi

    local separator='~'
    echo "$func_name() $separator $message"

    if (( malformed_args )); then
        exit 1
    fi
}

function handle_error {
    local func_name
    local error_message
    local fix_message
    local have_fix=0
    if (( $# == 0 || $# > 3 )); then
        func_name="${FUNCNAME[0]}"
        error_message="arguments are <function_name> [error_message] [fix_message]"        
    elif (( $# >= 1 )); then # 1 <= $# <= 3
        func_name="$1"

        error_message="Someting went wrong"
        if (( $# >= 2 )); then
            error_message="$2"
        fi

        if (( $# == 3 )); then
            have_fix=1
            fix_message="$3"
        fi
    fi

    log_message "$func_name" "Error: $error_message"
    if (( have_fix )); then
        log_message "$func_name" "Fix: $fix_message"
    fi
    
    exit 1
}

function main {
    local func_name="${FUNCNAME[0]}"

    local script_path
    if ! script_path=$(realpath "$0"); then
        handle_error "$func_name" "failed to resolve script_path"
    fi

    local script_dir
    if ! script_dir=$(dirname "$script_path"); then
        handle_error "$func_name" "failed to resolve script_dir"
    fi
    
    local repo_dir
    if ! repo_dir=$(dirname "$script_dir"); then
        handle_error "$func_name" "failed to resolve repo_dir"
    fi
    
    local bin_dir="$repo_dir/bin"
    local ggen_binary="ggen"
    local build_command="cd $repo_dir; make $ggen_binary"
    if [[ ! -d "$bin_dir" ]]; then
        handle_error "$func_name" "$bin_dir not found" "$build_command"
    fi

    ggen_path="$bin_dir/$ggen_binary"
    if [[ ! -f "$ggen_path" ]]; then
        handle_error "$func_name" "$ggen_path not found" "$build_command"
    fi

    log_message "$func_name" "$ggen_binary found in $ggen_path"

    exit 0
}

main "$@"