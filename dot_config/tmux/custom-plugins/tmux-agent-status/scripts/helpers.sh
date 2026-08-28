#!/usr/bin/env bash
#
# tmux-agent-status: shared helpers, sourced by agent-status.tmux and
# scripts/agent-status.sh. Not itself executable -- always sourced.

# tmux_option <name> <default>
#
# Read a global tmux option, falling back to <default> when unset/empty.
tmux_option() {
  local value
  value=$(tmux show-option -gqv "$1")
  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$2"
  fi
}

# resolve_format <format>
#
# Expand a tmux format string (e.g. "#{@thm_yellow}") to its literal value.
# Needed because a script reading options via `tmux show -g` gets the raw,
# uninterpolated string -- the same problem the sidebar colour block in
# tmux.conf works around for catppuccin's @thm_* palette.
resolve_format() {
  tmux display-message -p "$1"
}
