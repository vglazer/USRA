#! /usr/bin/env bash

GGEN_BINARY="ggen"
SCRIPT_DIR=$(dirname "$(realpath "$0")")
REPO_DIR=$(realpath "$SCRIPT_DIR/..")
BIN_DIR="$REPO_DIR/bin"
BUILD_COMMAND="cd $REPO_DIR; make $GGEN_BINARY"

function handle_error {
    local error_message
    if [ $# -ge 1 ]; then
        error_message=$1
    else
        error_message="Someting went wrong"
    fi

    local fix_message
    if [ $# -ge 2 ]; then
        fix_message=$2
    else
        fix_message="$BUILD_COMMAND"
    fi

    echo "Error: $error_message"
    echo "Fix: $fix_message"
    
    exit 1
}

# main

if [ ! -d "$BIN_DIR" ]; then
    handle_error "$BIN_DIR not found"
fi

# To resolve paths such as etc/../bin/
BIN_DIR=$(realpath "$BIN_DIR")

GGEN_PATH="$BIN_DIR/$GGEN_BINARY"
if [[ ! -f "$GGEN_PATH" ]]; then
    handle_error "$GGEN_PATH not found"
fi

echo "$GGEN_BINARY" found: "$GGEN_PATH"

exit 0