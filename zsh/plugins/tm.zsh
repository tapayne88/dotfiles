# Idempotent tmux startup function
function tm() {
  if [ "$1" = "-h" ]; then
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
  fi

  # destroy flag
  if [ "$1" = "-k" ]; then
    tmux kill-session -t $2
    return
  fi

  # list flag
  if [[ -z "$@" || "$1" = "-l" ]]; then
    tmux list-session
    return
  fi

  tmux has-session -t "$1" > /dev/null 2>&1

  if [ $? -ne 0 ]; then
    tmux new -d -s "$1" -c "$HOME"
  fi

  if [ -n "$TMUX" ]; then
    tmux switch -t "$1"
  else
    tmux attach -t "$1"
  fi
}
