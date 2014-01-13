#!/bin/bash
#set -e
#set -x

usage() {
    cat << _END_
SYNOPSIS
    $0 STOPTIME
    ex. $0 0030
_END_
}

if [ "X$1" == "X" ]; then
    usage
    exit 0
fi

cd ~/Work/Script/live_recording_of_blockfm
carton exec perl record_blockfm.pl
