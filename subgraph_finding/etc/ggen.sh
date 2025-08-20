#! /usr/bin/env bash

function handle_error {
    local error_message
    if [[ $# -ge 1 ]]; then
        error_message=$1
    else
        error_message="Someting went wrong"
    fi

    local have_fix=0
    local fix_message
    if [[ $# -ge 2 ]]; then
        have_fix=1
        fix_message=$2
    fi

    local func_name="${FUNCNAME[0]}() ~"
    echo "$func_name Error: $error_message"
    if (( have_fix )); then
        echo "$func_name Fix: $fix_message"
    fi
    
    exit 1
}

# main
GGEN_BINARY="ggen"
SCRIPT_DIR=$(dirname "$(realpath "$0")")
REPO_DIR=$(realpath "$SCRIPT_DIR/..")
BIN_DIR="$REPO_DIR/bin"
BUILD_COMMAND="cd $REPO_DIR; make $GGEN_BINARY"

if [[ ! -d "$BIN_DIR" ]]; then
    handle_error "$BIN_DIR not found" "$BUILD_COMMAND"
fi

GGEN_PATH="$BIN_DIR/$GGEN_BINARY"
if [[ ! -f "$GGEN_PATH" ]]; then
    handle_error "$GGEN_PATH not found" "$BUILD_COMMAND"
fi

echo "$GGEN_BINARY" found: "$GGEN_PATH"

exit 0