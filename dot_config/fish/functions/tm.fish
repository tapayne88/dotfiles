# Idempotent tmux startup function
function tm
    if test "$argv" = ""; or test "$argv[1]" = "-h"
        echo ""
        echo "tm - My handy function for managing tmux sessions"
        echo ""
        echo "Usage:"
        echo "   tm <flags> <args>"
        echo ""
        echo "Flags:"
        echo "   -h     Help, print his help message"
        echo "   -k     Kill named session (<args>)"
        echo "   -l     List sessions"
        echo ""
        return
    end

    # destroy flag
    if test "$argv[1]" = "-k"
        tmux kill-session -t $argv[2]
        return
    end

    # list flag
    if test "$argv[1]" = "-l"
        tmux list-session
        return
    end

    tmux has-session -t "$argv[1]" > /dev/null 2>&1

    if test $status -ne 0
        tmux new -d -s "$argv[1]" -c "~"
    end

    if test -n "$TMUX"
        tmux switch -t "$argv[1]"
    else
        tmux attach -t "$argv[1]"
    end
end
