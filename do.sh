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

carton=$HOME/.plenv/shims/carton
if [ `hostname` == 'dti-vps-srv85' ]; then
    cd $HOME/work/live_recording_of_blockfm
else
    cd $HOME/Work/Script/live_recording_of_blockfm
fi
$carton exec perl record_blockfm.pl $1
