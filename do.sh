#!/bin/bash
#set -e
#set -x

app=record_blockfm.pl
app_dir=live_recording_of_blockfm
if [ $MODE == 'production' ]; then
    base=$HOME/work/$app_dir
else
    base=$HOME/Work/Script/$app_dir
fi
carton=$HOME/.plenv/shims/carton

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

cd $base
$carton exec perl $app $1
