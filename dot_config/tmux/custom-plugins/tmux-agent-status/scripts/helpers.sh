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

# run_providers
#
# Run every provider named in @agent_status_providers (space-separated),
# resolving each from @agent_status_provider_path (checked first, if set)
# or this plugin's own providers/ directory. Prints the concatenated JSON
# array of all providers that returned valid output to stdout.
#
# Returns 1 (nothing printed) if no configured provider could be found or
# ran successfully -- distinct from a provider running and finding zero
# agents, which returns 0 with "[]". Callers that want to stay silent when
# nothing ran (rather than render an all-zero result) should check the
# return code, not just the output:
#   all_entries=$(run_providers) || exit 0
#
# A single broken provider (missing, non-zero exit, malformed JSON) never
# fails the whole call -- it just contributes nothing.
run_providers() {
  local helpers_dir plugin_dir providers_option provider_path
  helpers_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)
  plugin_dir=$(dirname "$helpers_dir")

  providers_option=$(tmux_option '@agent_status_providers' 'claude')
  provider_path=$(tmux_option '@agent_status_provider_path' '')

  local name dir exe out all_entries any_ran
  all_entries='[]'
  any_ran=0

  for name in $providers_option; do
    exe=""
    for dir in "$provider_path" "$plugin_dir/providers"; do
      [ -n "$dir" ] || continue
      if [ -x "$dir/$name" ]; then
        exe="$dir/$name"
        break
      fi
    done
    [ -n "$exe" ] || continue

    out=$("$exe" 2> /dev/null) || continue
    echo "$out" | jq -e 'type == "array"' > /dev/null 2>&1 || continue

    any_ran=1
    all_entries=$(jq -c -n --argjson a "$all_entries" --argjson b "$out" '$a + $b')
  done

  [ "$any_ran" -eq 1 ] || return 1
  echo "$all_entries"
}
