#!/bin/bash

SCRIPT="$(readlink -fn "$0")"

set -e

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
            black "$F"
            ;;
        js | html | css | md | json | jsx )
            echo "Running prettier on $F"
            prettier --write "$F"
            ;;
        *)
            echo "Don't know how to strip $SUFFIX files like $F"
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
    echo "Applying file-by-file to $*"
    for F in "$@"; do
        fix_file "$F"
    done
fi
