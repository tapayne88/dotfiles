#!/bin/bash
SESSION=work

if (tmux has-session -t $SESSION > /dev/null 2>&1); then
    tmux switch -t $SESSION
    exit 0
fi

# Start session
tmux new-session -d -s $SESSION

# Skybetdev tab
tab=${SESSION}:1
tmux rename-window -t $tab 'skybetdev'
tmux split-window -t $tab -h
tmux send-keys -t ${tab}.0 'z skybetdev' C-m
tmux send-keys -t ${tab}.1 'z skybetdev' C-m

# UI-Library tab
tab=${SESSION}:2
tmux new-window -t $tab -n 'ui-library'
tmux split-window -t $tab -h
tmux send-keys -t ${tab}.0 'z ui-library' C-m
tmux send-keys -t ${tab}.1 'z ui-library' C-m

# Cosmos tab
tab=${SESSION}:9
tmux new-window -t $tab -n 'cosmos'
tmux split-window -t $tab -p 100
tmux send-keys -t ${tab}.0 'z cosmos; ctop' C-m
tmux send-keys -t ${tab}.1 'z cosmos' C-m

tmux select-window -t $SESSION:1

tmux switch -t $SESSION
