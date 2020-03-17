#!/bin/bash

set -e
TIMEOUT=2
FLAGFILE="$(mktemp)"
OUTFILE="$(mktemp)"

cleanup() {
    rm -f "$FLAGFILE"
    rm -f "$OUTFILE"
}
trap cleanup SIGINT SIGTERM EXIT

monitor_for_exit() {
    local FLAGFILE=$1; shift
    local OUTFILE=$1; shift
    "$@" &> "$OUTFILE" || true
    rm -f "$FLAGFILE"
}

monitor_for_exit "$FLAGFILE" "$OUTFILE" "$@" &>/tmp/hide-log.txt &

ENDTIME=$(($(date +%s) + TIMEOUT))
while [ -e "$FLAGFILE" ] && [ "$(date +%s)" -lt "$ENDTIME" ]; do
    sleep 0.25
done

if [ -e "$FLAGFILE" ]; then
    tail -n +1 -f "$OUTFILE" &
    while [ -e "$FLAGFILE" ]; do sleep 0.25; done
fi

rm -f "$OUTFILE"
