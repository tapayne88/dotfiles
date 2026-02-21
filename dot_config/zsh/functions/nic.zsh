# Development tmux session setup
function nic() {
  if [[ "$1" == "-h" ]]; then
    echo "nic - create a development tmux session with neovim, opencode, and terminal panes"
    echo ""
    echo "Usage:"
    echo "  nic [-h] [directory]"
    echo ""
    echo "Arguments:"
    echo "  directory    Directory to start session in (defaults to current directory)"
    echo ""
    echo "Flags:"
    echo "  -h           Show this help message"
    echo ""
    echo "Layout:"
    echo "  ┌──────────────────────┬───────────┐"
    echo "  │                      │           │"
    echo "  │       neovim         │ opencode  │"
    echo "  │        (nvim)        │  (30%)    │"
    echo "  │                      │           │"
    echo "  ├──────────────────────┴───────────┤"
    echo "  │           terminal (20%)         │"
    echo "  └──────────────────────────────────┘"
    echo ""
    echo "If a session with the same name already exists, attaches to it."
    return
  fi

  local dir="${1:-$PWD}"
  dir="${dir:A}"
  local session_name="${dir:t}"

  # Determine attach or switch based on whether we're in tmux
  local attach_cmd
  if [[ -n "$TMUX" ]]; then
    attach_cmd="switch-client"
  else
    attach_cmd="attach-session"
  fi

  # If session exists, just attach/switch to it
  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux $attach_cmd -t "$session_name"
    return
  fi

  # Create new detached session
  tmux new-session -d -s "$session_name" -c "$dir" -x "$(tput cols)" -y "$(tput lines)"

  # Split bottom 20% (full width) for terminal
  tmux split-window -v -l 20% -t "$session_name:1.0" -c "$dir"

  # Split right 30% for opencode
  tmux split-window -h -l 30% -t "$session_name:1.0" -c "$dir"

  # Start applications
  tmux send-keys -t "$session_name:1.0" "nvim" C-m
  tmux send-keys -t "$session_name:1.1" "opencode --port" C-m

  # Focus neovim pane
  tmux select-pane -t "$session_name:1.0"

  # Attach/switch to the session
  tmux $attach_cmd -t "$session_name"
}
