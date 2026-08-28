#!/usr/bin/env bash
#
# tmux-agent-status renderer.
#
# Invoked via #() from status-right/status-left on every status-interval
# tick. Must be fast and must never let a failure surface as literal error
# text in the status bar -- on any problem it prints nothing.

set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)
plugin_dir=$(dirname "$script_dir")

# shellcheck source=./helpers.sh
source "$script_dir/helpers.sh"

command -v jq > /dev/null 2>&1 || exit 0
command -v tmux > /dev/null 2>&1 || exit 0

providers_option=$(tmux_option '@agent_status_providers' 'claude')
provider_path=$(tmux_option '@agent_status_provider_path' '')

# Defaults are Nerd Font glyphs: hourglass (waiting), play (running), check
# (done) -- written as \xHH UTF-8 byte escapes (nf-fa-hourglass-half U+F252,
# nf-fa-play U+F04B, nf-fa-check U+F00C) so the raw bytes survive regardless
# of editor/terminal encoding. Override via the @agent_status_icon_* options
# for a non-Nerd-Font terminal.
icon_waiting=$(tmux_option '@agent_status_icon_waiting' "$(printf '\xef\x89\x92')")
icon_running=$(tmux_option '@agent_status_icon_running' "$(printf '\xef\x81\x8b')")
icon_done=$(tmux_option '@agent_status_icon_done' "$(printf '\xef\x80\x8c')")

color_waiting=$(tmux_option '@agent_status_resolved_color_waiting' '')
color_running=$(tmux_option '@agent_status_resolved_color_running' '')
color_done=$(tmux_option '@agent_status_resolved_color_done' '')

separator=$(tmux_option '@agent_status_separator' '  ')

# Locate a provider executable by name: user path first, then the bundled
# providers/ directory.
find_provider() {
  local name=$1 dir
  for dir in "$provider_path" "$plugin_dir/providers"; do
    [ -n "$dir" ] || continue
    if [ -x "$dir/$name" ]; then
      echo "$dir/$name"
      return 0
    fi
  done
  return 1
}

all_entries='[]'
any_ran=0

for name in $providers_option; do
  exe=$(find_provider "$name") || continue

  out=$("$exe" 2> /dev/null) || continue
  echo "$out" | jq -e 'type == "array"' > /dev/null 2>&1 || continue

  any_ran=1
  all_entries=$(jq -c -n --argjson a "$all_entries" --argjson b "$out" '$a + $b')
done

# If nothing ran (no providers configured/found, or all failed), stay silent
# rather than render a misleading all-zero segment.
[ "$any_ran" -eq 1 ] || exit 0

counts=$(echo "$all_entries" | jq -c '
  reduce .[] as $e (
    {waiting: 0, running: 0, done: 0};
    if $e.state == "waiting" then .waiting += 1
    elif $e.state == "running" then .running += 1
    elif $e.state == "done" then .done += 1
    else .
    end
  )
')

n_waiting=$(echo "$counts" | jq -r '.waiting')
n_running=$(echo "$counts" | jq -r '.running')
n_done=$(echo "$counts" | jq -r '.done')

printf '#[fg=%s]%s %s#[default]%s#[fg=%s]%s %s#[default]%s#[fg=%s]%s %s#[default]' \
  "$color_waiting" "$icon_waiting" "$n_waiting" "$separator" \
  "$color_running" "$icon_running" "$n_running" "$separator" \
  "$color_done" "$icon_done" "$n_done"
