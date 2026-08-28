#!/usr/bin/env bash
#
# tmux-agent-status: per-session agent summary, for consumers outside the
# tmux status bar (currently: the `tmux-sessions` television channel).
#
# Prints one line per live tmux session that has at least one agent, TSV:
#   <session name>\t<ANSI-coloured summary>
#
# Unlike the status-bar renderer (scripts/agent-status.sh), which emits
# tmux's own "#[fg=#hex]" format syntax -- meaningful only inside a tmux
# status-line string tmux itself interprets -- this prints genuine ANSI SGR
# truecolor escapes, since consumers here read raw command output directly
# (e.g. television's `ansi = true` channels). The two are not
# interchangeable; see the README's "Television session switcher
# integration" section.
#
# Must never fail loudly: on any problem this prints nothing and exits 0.

set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)

# shellcheck source=./helpers.sh
source "$script_dir/helpers.sh"

command -v jq > /dev/null 2>&1 || exit 0
command -v tmux > /dev/null 2>&1 || exit 0

icon_waiting=$(tmux_option '@agent_status_icon_waiting' "$(printf '\xef\x89\x92')")
icon_running=$(tmux_option '@agent_status_icon_running' "$(printf '\xef\x81\x8b')")
icon_done=$(tmux_option '@agent_status_icon_done' "$(printf '\xef\x80\x8c')")

color_waiting=$(tmux_option '@agent_status_resolved_color_waiting' '')
color_running=$(tmux_option '@agent_status_resolved_color_running' '')
color_done=$(tmux_option '@agent_status_resolved_color_done' '')

separator=$(tmux_option '@agent_status_separator' '  ')

all_entries=$(run_providers) || exit 0

# hex_to_ansi <#rrggbb> <icon> <n>
#
# Build one "ESC[38;2;R;G;Bm<icon> <n>ESC[0m" truecolor segment. Falls back
# to no colour codes (plain text) if the hex value is missing/malformed, so
# a misconfigured @agent_status_color_* option degrades to uncoloured text
# rather than garbage escape sequences.
hex_to_ansi() {
  local hex=$1 icon=$2 n=$3
  case "$hex" in
  '#'[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])
    local r g b
    r=$((16#${hex:1:2}))
    g=$((16#${hex:3:2}))
    b=$((16#${hex:5:2}))
    printf '\033[38;2;%d;%d;%dm%s %s\033[0m' "$r" "$g" "$b" "$icon" "$n"
    ;;
  *)
    printf '%s %s' "$icon" "$n"
    ;;
  esac
}

echo "$all_entries" | jq -c '
  map(select(.session != null and .session != ""))
  | group_by(.session)
  | map({
      session: .[0].session,
      waiting: (map(select(.state == "waiting")) | length),
      running: (map(select(.state == "running")) | length),
      done: (map(select(.state == "done")) | length)
    })
' | jq -r '.[] | [.session, .waiting, .running, .done] | @tsv' |
  while IFS=$'\t' read -r session n_waiting n_running n_done; do
    parts=()
    [ "$n_waiting" -gt 0 ] && parts+=("$(hex_to_ansi "$color_waiting" "$icon_waiting" "$n_waiting")")
    [ "$n_running" -gt 0 ] && parts+=("$(hex_to_ansi "$color_running" "$icon_running" "$n_running")")
    [ "$n_done" -gt 0 ] && parts+=("$(hex_to_ansi "$color_done" "$icon_done" "$n_done")")

    [ ${#parts[@]} -eq 0 ] && continue

    summary=""
    for i in "${!parts[@]}"; do
      if [ "$i" -eq 0 ]; then
        summary="${parts[$i]}"
      else
        summary="$summary$separator${parts[$i]}"
      fi
    done

    printf '%s\t%s\n' "$session" "$summary"
  done
