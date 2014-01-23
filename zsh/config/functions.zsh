# List processes via pgrep, then prompt to pkill - Thanks Glen
pgk() {
    [ -z "$*" ] && echo 'Usage: pgk <pattern>' && return 1
    pgrep -fl $*
    [ "$?" = "1" ] && echo 'No processes match' && return 1
    echo 'Hit [Enter] to pkill, [Ctrl+C] to abort'
    read && pkill -f $*
}
