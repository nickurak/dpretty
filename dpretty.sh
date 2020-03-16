#!/bin/bash

SCRIPT="$(readlink -fn "$0")"

set -e

export GIT_AUTHOR_NAME="Dpretty Formatter"
export GIT_AUTHOR_EMAIL="dpretty-formatter@nonexistant.invalid"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

while getopts :g:r: OPT; do
    case $OPT in
        g)
            GITDIR="$OPTARG"
            ;;
        r)
            GITRANGE=$OPTARG
            ;;
        *)
            echo "Invalid option: $OPTARG" >/dev/stderr
            exit 1
    esac
done
shift "$(expr "$OPTIND" - 1 )"

fix_range() {
    local GITDIR="$1"; shift
    local GITRANGE="$1"; shift
    pushd "$GITDIR" &>/dev/null
    git-rapply "$SCRIPT" "$GITRANGE"
    popd
}

fix_file() {
    local F=$1; shift
    BASE="$(basename "$F")"
    SUFFIX="${BASE/#*./}"
    case "$SUFFIX" in
        py)
            echo "Running black on $F"
            chronic black "$F"
            ;;
        js | html | css | md | jsx )
            echo "Running prettier on $F"
            chronic prettier --write "$F"
            ;;
        *)
            true
            ;;
    esac
}

if [ -n "$GITDIR" ]; then
    if [ -z "$GITRANGE" ]; then
        GITRANGE="@{upstream}.."
    fi
    if [ -n "$*" ]; then
        echo "Additional parameters \"$*\" found, not allowed with -g/-r"
        exit 1
    fi
    echo "Applying to Git dir $GITDIR on range $GITRANGE"
    fix_range "$GITDIR" "$GITRANGE"
else
    if [ -n "$GITRANGE" ]; then
        echo "-r can't be used without -g" > /dev/stderr
        exit 1
    fi
    for F in "$@"; do
        fix_file "$F"
    done
fi
