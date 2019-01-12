#!/usr/bin/env sh

WIDTH=`tmux display -p "#{client_width}"`
SMALL=100

if [ $WIDTH -le $SMALL ]; then
    exit 0
fi

exit 1
