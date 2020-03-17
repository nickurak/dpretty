#!/bin/bash

set -e
set -o errtrace
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$SCRIPTDIR"

TEST_ROOT="$(mktemp -d)"
LOG="${TEST_ROOT}/log"

export GIT_AUTHOR_NAME="Dpretty tests"
export GIT_AUTHOR_EMAIL="dpretty-tests@nonexistant.invalid"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

cleanup() {
    [ -n "$TEST_ROOT" ] && [ -d "$TEST_ROOT" ] && rm -Rf "$TEST_ROOT"
}

error() {
    cat "$TEST_ROOT"/log
    cleanup
}

trap "error" SIGINT SIGTERM ERR

FAILURES=()
fail() {
    local MSG="$@"
    FAILURES+=( "$MSG" )
}

run_test() {
    local INPUT="${SCRIPTDIR}/${1}.input"
    local OUTPUT="${SCRIPTDIR}/${1}.output"
    local EXPECTED="${SCRIPTDIR}/${1}.expected"
    local FIRST_COMMIT="$2"
    local TEST_GIT_DIR="${TEST_ROOT}/${1}/git"
    local DIFF="$TEST_ROOT/${1}/diff"
    mkdir -p "$TEST_GIT_DIR"
    cd "$TEST_GIT_DIR"
    git init >>"$LOG" 2>&1
    git commit --allow-empty -m "init" >>"$LOG" 2>&1
    INITIAL_COMMIT="$(git log -1 --pretty=%H)"
    [ -z "$FIRST_COMMIT" ] && FIRST_COMMIT="$INITIAL_COMMIT"
    cat "$INPUT" | git am - >>"$LOG" 2>&1
    git log --reverse -p --topo-order > "$INPUT-log"
    "${SCRIPTDIR}/../dpretty" -r "$FIRST_COMMIT.." >>"$LOG" 2>&1
    git log --reverse -p --topo-order > "$OUTPUT"
    local BLURSED='/^(commit |Date: )/d'
    if ! diff -u <(sed -E "$BLURSED" "$OUTPUT") <(sed -E "$BLURSED" "$EXPECTED") > "$DIFF"; then
        echo "Test $1 failed, difference:"
        cat "$DIFF"
        fail "Test $1 failed"
    fi
    cd "$SCRIPTDIR"
}

for TEST in *.test; do
    NAME="${TEST%.test}"
    . "$TEST"
    run_test "$NAME" "$START"
done

cleanup
if [ ${#FAILURES[@]} -gt 0 ]; then
    echo "${#FAILURES[@]} test failed:"
    for MSG in "${FAILURES[@]}"; do
        echo "$MSG"
    done
    exit 1
fi
echo "All test suites passed."
