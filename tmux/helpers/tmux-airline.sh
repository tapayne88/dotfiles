#!/usr/bin/env sh

WIDTH=${1}

SMALL=100
MEDIUM=140

KUBE_COLOUR="#[fg=brightBlack,bg=brightBlue]"
BATTERY_COLOUR="#[fg=yellow,bg=brightBlack]"

KUBE=""
BATTERY=""
DATE="%a %d-%m-%Y"

KUBE_CLUSTER=`~/.tmux/plugins/tmux-kube/scripts/kube_cluster.sh`
KUBE_NAMESPACE=`~/.tmux/plugins/tmux-kube/scripts/kube_namespace.sh`
if [ "$KUBE_CLUSTER:$KUBE_NAMESPACE" != ":" ]; then
    HAS_KUBE="TRUE"
else
    HAS_KUBE=""
fi

source ~/.tmux/plugins/tmux-battery/scripts/helpers.sh
HAS_BATTERY=`battery_status`
BATTERY_PERCENTAGE=`~/.tmux/plugins/tmux-battery/scripts/battery_percentage.sh`

[ "$HAS_KUBE" != "" ] && KUBE=" ⎈  $KUBE_CLUSTER:$KUBE_NAMESPACE "
[ "$HAS_BATTERY" != "" ] && BATTERY=" ⚡  $BATTERY_PERCENTAGE "

if [ $WIDTH -le $MEDIUM ]; then
    if [ $HAS_KUBE ]; then
        KUBE=" ⎈  "
    fi
fi

if [ $WIDTH -le $SMALL ]; then
    if [ $HAS_KUBE ]; then
        KUBE=" ⎈  "
    fi
    if [ $HAS_BATTERY ]; then
        BATTERY=" $BATTERY_PERCENTAGE "
    fi
    DATE="%d-%m-%y"
fi

KUBE_STATUS="$KUBE"
BATTERY_STATUS="$BATTERY_COLOUR$BATTERY"
BASIC="#[fg=white,bg=brightblack,nobold,noitalics,nounderscore] `date +\"$DATE\"` #[fg=black,bg=blue] `date +\"%H:%M\"`"

echo "$KUBE_STATUS$BASIC $BATTERY_STATUS"
