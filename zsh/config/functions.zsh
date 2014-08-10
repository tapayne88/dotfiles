# List processes via pgrep, then prompt to pkill - Thanks Glen
pgk() {
    [ -z "$*" ] && echo 'Usage: pgk <pattern>' && return 1
    pgrep -fl $*
    [ "$?" = "1" ] && echo 'No processes match' && return 1
    echo 'Hit [Enter] to pkill, [Ctrl+C] to abort'
    read && pkill -f $*
}

# Idempotent tmux startup function
tm() {
    # destroy flag
    if [ $1 = '-k' ] || [ $1 = '-d' ]; then
        tmux kill-session -t $2
        return
    fi

    # list flag
    if [ $1 = '-l' ]; then
        tmux list-session
        return
    fi

    tmux has-session -t $1 > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        TMUX= tmux new-session -d -s $1
    fi

    if [ -n "$TMUX" ];then
        tmux switch -t $1
    else
        tmux attach -t $1
    fi
}

# IRC startup function
irc() {
    tmux new-window -t 0 -n 'irssi' 'irssi'

    tmux split-window -h -l 20 -t 0 "cat ~/.irssi/nicklistfifo"
    tmux last-pane
}

# Function to quickly tail vagrant logs
vlogs() {
    tmux new-window -t 9 -n 'log' "ssh -i ~/.vagrant.d/insecure_private_key -p 2222 vagrant@127.0.0.1 'tailf /var/lamp/logs/application.log'"
}
