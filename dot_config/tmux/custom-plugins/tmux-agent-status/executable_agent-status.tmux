#!/usr/bin/env bash
#
# tmux-agent-status entrypoint.
#
# With no arguments: run by tmux.conf via `run-shell` at config load (after
# tpm, so catppuccin's @thm_* options exist). Resolves the segment's colours
# to literal hex and substitutes the #{agent_status} placeholder into
# status-left/status-right, mirroring the mechanism tmux-prefix-highlight
# uses for its own placeholder.
#
# With a subcommand: manual, one-off admin actions -- never run automatically
# by tmux. See usage() below.

set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)

# shellcheck source=./scripts/helpers.sh
source "$script_dir/scripts/helpers.sh"

place_holder='#{agent_status}'
renderer="$script_dir/scripts/agent-status.sh"

usage() {
  cat << EOF
Usage: $(basename "${BASH_SOURCE[0]}") [command]

Commands:
  (none)                  Install the status bar segment (run by tmux.conf)
  install-claude-hooks    Add Claude Code hooks for instant status refresh
  uninstall-claude-hooks  Remove hooks added by install-claude-hooks
  -h, --help              Print this help and exit
EOF
}

# resolve_colours: cache @thm_* references as literal hex, once, at load.
# A script reading options via `tmux show -g` gets the raw uninterpolated
# "#{@thm_yellow}" string, so this has to happen inside a tmux command
# context (display-message), not inside the renderer.
resolve_colours() {
  local state default
  for state in waiting running "done"; do
    case "$state" in
    waiting) default='#{@thm_yellow}' ;;
    running) default='#{@thm_green}' ;;
    done) default='#{@thm_blue}' ;;
    esac
    local fmt
    fmt=$(tmux_option "@agent_status_color_${state}" "$default")
    tmux set-option -gq "@agent_status_resolved_color_${state}" "$(resolve_format "$fmt")"
  done
}

install_segment() {
  resolve_colours

  local placement
  for placement in status-left status-right; do
    local current
    current=$(tmux_option "$placement" '')
    [ -n "$current" ] || continue
    case "$current" in
    *"$place_holder"*)
      tmux set-option -gq "$placement" "${current//$place_holder/#($renderer)}"
      ;;
    esac
  done
}

# ---------------------------------------------------------------------------
# install-claude-hooks / uninstall-claude-hooks
# ---------------------------------------------------------------------------
#
# Opt-in accelerator: makes Claude Code force an immediate status bar repaint
# on Stop/Notification/SessionEnd, instead of waiting for the next
# status-interval tick. The core works fine without this -- it's purely a
# latency improvement, and it is never run automatically.

hook_marker='tmux-agent-status'
hook_command=": $hook_marker && tmux list-clients -F \"#{client_name}\" 2>/dev/null | xargs -r -n1 tmux refresh-client -S -t"

claude_settings_file() {
  echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
}

require_jq() {
  command -v jq > /dev/null 2>&1 || {
    echo "error: jq is required for $1" >&2
    exit 1
  }
}

backup_settings() {
  local file=$1 backup
  # mktemp for a guaranteed-unique name -- `date +%s` alone can collide if
  # install/uninstall run twice within the same second.
  backup=$(mktemp "$file.bak.XXXXXX")
  cp "$file" "$backup"
}

install_claude_hooks() {
  require_jq install-claude-hooks
  local file
  file=$(claude_settings_file)
  [ -f "$file" ] || echo '{}' > "$file"

  if jq -e --arg m "$hook_marker" '
      [.hooks[]?[]?.hooks[]?.command? // empty] | any(contains($m))
    ' "$file" > /dev/null 2>&1; then
    echo "tmux-agent-status hooks already installed in $file"
    return 0
  fi

  backup_settings "$file"

  local tmp
  tmp=$(mktemp)
  jq --arg cmd "$hook_command" '
    .hooks //= {} |
    (.hooks.Stop //= []) |
    (.hooks.Notification //= []) |
    (.hooks.SessionEnd //= []) |
    .hooks.Stop += [{"hooks": [{"type": "command", "command": $cmd}]}] |
    .hooks.Notification += [{"hooks": [{"type": "command", "command": $cmd}]}] |
    .hooks.SessionEnd += [{"hooks": [{"type": "command", "command": $cmd}]}]
  ' "$file" > "$tmp" && mv "$tmp" "$file"

  echo "Installed tmux-agent-status hooks into $file (backup written alongside it)"
}

uninstall_claude_hooks() {
  require_jq uninstall-claude-hooks
  local file
  file=$(claude_settings_file)
  [ -f "$file" ] || return 0

  if ! jq -e --arg m "$hook_marker" '
      [.hooks[]?[]?.hooks[]?.command? // empty] | any(contains($m))
    ' "$file" > /dev/null 2>&1; then
    echo "tmux-agent-status hooks not installed in $file"
    return 0
  fi

  backup_settings "$file"

  local tmp
  tmp=$(mktemp)
  jq --arg m "$hook_marker" '
    .hooks |= (
      with_entries(
        .value |= map(select(
          (.hooks // []) | any(.command? // "" | contains($m)) | not
        ))
      )
      | with_entries(select(.value | length > 0))
    )
    | if (.hooks | length) == 0 then del(.hooks) else . end
  ' "$file" > "$tmp" && mv "$tmp" "$file"

  echo "Removed tmux-agent-status hooks from $file (backup written alongside it)"
}

case "${1-}" in
'') install_segment ;;
install-claude-hooks) install_claude_hooks ;;
uninstall-claude-hooks) uninstall_claude_hooks ;;
-h | --help) usage ;;
*)
  echo "Unknown command: $1" >&2
  usage >&2
  exit 1
  ;;
esac
