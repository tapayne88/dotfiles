# tmux-agent-status

A tmux status bar segment showing counts of coding agents by state:
waiting for input, running, or done.

Agent-agnostic by design: the core knows nothing about any particular coding
agent. It aggregates over pluggable **provider** executables, each
responsible for detecting one kind of agent. Claude Code is the only
provider shipped today.

```
 2   1   6
```

## How it's wired in

`tmux.conf` places the `#{agent_status}` placeholder anywhere in
`status-left` / `status-right`:

```tmux
set -g status-right "#{agent_status}#{prefix_highlight}"
```

and loads the plugin after tpm:

```tmux
run-shell '$XDG_CONFIG_HOME/tmux/custom-plugins/tmux-agent-status/agent-status.tmux'
```

At load, `agent-status.tmux`:

1. Resolves the segment's colours (which may reference theme options like
   `#{@thm_yellow}`) to literal hex, since a script reading options via
   `tmux show -g` gets the raw, uninterpolated string.
2. Replaces every `#{agent_status}` placeholder in `status-left` /
   `status-right` with `#(.../scripts/agent-status.sh)`, the same mechanism
   `tmux-prefix-highlight` uses for its own placeholder.

From then on, tmux re-runs `scripts/agent-status.sh` on every
`status-interval` tick (the tmux default, 15s).

## Provider contract

A provider is any executable that prints a **JSON array** to stdout and
exits 0:

```json
[
  {
    "state": "waiting",
    "pane": "%15",
    "name": "lookup-eval-quoting-issue",
    "cwd": "/path/to/repo",
    "reason": "permission prompt",
    "agent": "claude"
  }
]
```

- `state` is **required**, and must be `waiting`, `running`, or `done`. Any
  other value is dropped.
- `pane`, `name`, `cwd`, `reason`, `agent` are optional. The core only
  aggregates on `state` today; the rest are carried through for future
  features (jump-to-pane, per-window indicators) without a contract change.
- Print `[]` when there are no agents.
- Non-zero exit, empty output, or unparseable JSON must be treated by the
  core as "this provider contributed nothing" -- a broken provider must
  never break the status bar.

Providers are resolved by name from `providers/` in this plugin directory,
and, if set, from `@agent_status_provider_path` (checked first, so a user
override wins).

### Writing a new provider

1. Add an executable to `providers/<name>` (or your own
   `@agent_status_provider_path` directory).
2. Add `<name>` to `@agent_status_providers` (space-separated).
3. Test it in isolation: `providers/<name> | jq .`

## Options

| Option                        | Default           | Notes                           |
| ----------------------------- | ----------------- | ------------------------------- |
| `@agent_status_providers`     | `claude`          | Space-separated provider names  |
| `@agent_status_provider_path` | (unset)           | Extra directory to search first |
| `@agent_status_icon_waiting`  | (hourglass)       | Nerd Font glyph                 |
| `@agent_status_icon_running`  | (play)            | Nerd Font glyph                 |
| `@agent_status_icon_done`     | (check)           | Nerd Font glyph                 |
| `@agent_status_color_waiting` | `#{@thm_yellow}`  | Any tmux colour/format          |
| `@agent_status_color_running` | `#{@thm_green}`   | Any tmux colour/format          |
| `@agent_status_color_done`    | `#{@thm_blue}`    | Any tmux colour/format          |
| `@agent_status_separator`     | `  ` (two spaces) | Between segments                |

## Claude Code hook accelerator (optional)

The 15s `status-interval` poll is the baseline and requires no
configuration. For instant repaint on state changes, install hooks that
force a tmux client refresh on `Stop`, `Notification`, and `SessionEnd`:

```sh
~/.config/tmux/custom-plugins/tmux-agent-status/agent-status.tmux install-claude-hooks
```

This merges into (not replaces) `~/.claude/settings.json`'s existing
`hooks` key, writes a timestamped backup alongside it first, and is
idempotent -- running it again is a no-op. Reverse it with:

```sh
~/.config/tmux/custom-plugins/tmux-agent-status/agent-status.tmux uninstall-claude-hooks
```

## Claude Code provider details

Reads `~/.claude/sessions/<pid>.json`, the native session registry Claude
Code itself maintains and push-updates on every status transition.

- Only `kind: "interactive"` sessions are counted; background/daemon workers
  are excluded.
- Liveness is checked with `kill -0 <pid>` plus a `ps -o comm=` match on
  `claude`, guarding against a stale file whose PID has been reused by an
  unrelated process.
- State mapping: `waiting` -> `waiting`; `busy` / `shell` -> `running`;
  `idle` -> `done`. There is no "seen" tracking -- an agent idle for days
  still counts as done.
