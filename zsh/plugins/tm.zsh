# Idempotent tmux startup function
function tm() {
  if [ "$1" = "-h" ]; then
    echo "tm - create new tmux session, or switch to existing one. Also kill"
    echo ""
    echo "Usage:"
    echo "   tm <flags> <session>"
    echo ""
    echo "Flags:"
    echo "   -h     Help, print his help message"
    echo "   -k     Kill named session or using fzf"
    echo ""
    echo "\`tm\` will allow you to select your tmux session via fzf."
    echo "\`tm irc\` will attach to the irc session (if it exists), else it will create it."
    return
  fi

  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"

  # destroy flag
  if [ "$1" = "-k" ]; then
    change="kill-session"
    if [ $2 ]; then
      tmux $change -t $2; return
    fi
  elif [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi

  session=$(tmux list-sessions 2>/dev/null | fzf --header $change | cut -f 1 -d':') && [ $session ] && tmux $change -t "$session" || echo "No sessions found."
}
