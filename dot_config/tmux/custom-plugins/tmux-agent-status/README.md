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
    "session": "agents-mono",
    "name": "lookup-eval-quoting-issue",
    "cwd": "/path/to/repo",
    "reason": "permission prompt",
    "agent": "claude"
  }
]
```

- `state` is **required**, and must be `waiting`, `running`, or `done`. Any
  other value is dropped.
- `pane`, `session`, `name`, `cwd`, `reason`, `agent` are optional. The core
  only aggregates on `state` today; the rest are carried through for other
  consumers (e.g. `session`, added for the television integration below)
  without a contract change.
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

## Harness support

The core polls providers on `status-interval` -- hooks are never required by
the core itself. Whether a provider can be pure polling depends entirely on
whether the harness maintains queryable state on its own:

| Harness      | Pollable?  | Detail                                                                                                                                                                                             |
| ------------ | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Claude Code  | Yes, fully | `~/.claude/sessions/<pid>.json`: `status`, `waitingFor`, tmux pane, pid for liveness -- see below                                                                                                  |
| cursor-agent | No         | `~/.config/cursor/chats/<hash>/<id>/meta.json` has only `updatedAtMs` -- no pid, no status. Has hooks (`~/.cursor/hooks.json`)                                                                     |
| Copilot CLI  | Barely     | `~/.copilot/session-state/<uuid>/events.jsonl` gives running-vs-idle from turn events, but no pid and no way to see "waiting for permission" -- indistinguishable from a long tool call. Has hooks |
| opencode     | No (moot)  | State is exposed over HTTP/SSE only (`session.status`, `permission.updated`); nothing pollable on disk                                                                                             |

A provider for a push-only harness needs a hook to write a state file first;
the provider then just reads that file. The provider contract above doesn't
need to change to accommodate this -- only the question of who writes the
state differs. Note the Copilot trap in particular: its event log can tell
you running vs idle but never "waiting for permission", so a naive Copilot
provider would silently under-report exactly the state this status bar
exists to surface.

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
configuration; the Claude provider works fully without any hooks installed.
This section is purely a latency optimisation -- unlike the push-only
harnesses above, Claude Code doesn't _need_ hooks to be pollable, it just
repaints faster with them. Install hooks that force a tmux client refresh on
`Stop`, `Notification`, and `SessionEnd`:

```sh
~/.config/tmux/custom-plugins/tmux-agent-status/agent-status.tmux install-claude-hooks
```

This merges into (not replaces) `~/.claude/settings.json`'s existing
`hooks` key, writes a timestamped backup alongside it first, and is
idempotent -- running it again is a no-op. Reverse it with:

```sh
~/.config/tmux/custom-plugins/tmux-agent-status/agent-status.tmux uninstall-claude-hooks
```

## Television session switcher integration

`scripts/session-summary.sh` rolls up provider output per `session` (not
per pane) and prints one `<session name>\t<summary>` line per tmux session
that has at least one agent -- consumed by
`dot_config/television/cable/tmux-sessions.toml`'s `tv tmux-sessions`
channel, which left-joins it onto the session list as an extra column.

**This is not the same colour encoding as the status bar.** The renderer
above emits tmux's own `#[fg=#hex]` format syntax, meaningful only inside a
tmux status-line string that tmux itself interprets -- printed as-is to a
plain command's stdout, it would show up as literal garbage text.
`session-summary.sh` instead builds real ANSI SGR truecolor escapes
(`\033[38;2;R;G;Bm...\033[0m`) from the same resolved
`@agent_status_resolved_color_*` hex values, for consumers like television
that read raw output directly (`[source] ansi = true`). Don't reuse the
renderer's output for a non-tmux consumer; build from the resolved hex
values instead, the way this script does.

The TOML `[source].command` writes the script's output to a temp file and
has `awk` join on it via `getline` rather than passing it through `-v` --
POSIX `-v var=value` treats the value as an awk string literal, and a raw
newline embedded in that value (which a multi-line summary always has)
breaks the parse. Reading it as a second input file sidesteps that
entirely.

**The channel has no custom `display` key, on purpose.** The first attempt
built the visible row via `display = "{split:\t:0} ({split:\t:1}) ..."`,
combining plain and ANSI-bearing fields through the template engine --
which doesn't reliably preserve embedded escape codes assembled that way.
None of this repo's other `ansi = true` channels (`git-log`, `git-stash`,
`text`, `todo-comments`) set `display` either; they all rely on the
default raw-entry display and only `strip_ansi` for `output`/`preview`/
`actions`. This channel follows the same pattern: `awk` prints the fully
formatted, colour-bearing row directly as the entry's second field
(`name`, `(N windows) <summary>`), and the default `{}` display shows it
as-is. `output`/`preview`/`actions` still read `{split:\t:0}` (the plain
name, untouched), so they need no `strip_ansi`.

The status summary column is right-aligned by having `awk` collect all
rows first, compute the longest session name and windows-count string
across the batch, then pad in an `END` block. The padding is pure leading
spaces (`%*s` with an empty string), not a repeated, right-justified copy
of the name -- repeating the name looked reasonable in isolation but threw
alignment off, because the raw tab separating field 0 (plain name, for
`output`) from field 1 (the padded display text) renders with a roughly
constant width regardless of what precedes it, not a real tab-stop
calculation. Padding with plain spaces (which don't share that quirk)
combines with that constant tab width correctly; padding with a
name-repeat does not, since the redundant name's varying length then
un-cancels the alignment.

Refresh is manual: television's existing `ctrl-r` (`reload_source`,
`config.toml`) re-runs the source command, including the summary. No
`watch`-based polling is configured.

## Claude Code provider details

Reads `~/.claude/sessions/<pid>.json`, the native session registry Claude
Code itself maintains and push-updates on every status transition.

- Output is always exactly one entry per live `kind: "interactive"` session
  -- one per navigable tmux pane. `kind: "bg"` records (background job
  workers) are never emitted on their own.
- A parked interactive session (working via a background job, e.g. through
  `/loop` or a spawned agent) is rolled up into its worker's status instead
  of reporting its own idle-while-parked status: the interactive record's
  `parkedJobId` is matched exactly against the live `bg` record's `jobId`.
  If no live worker matches, the interactive record's own status is used.
- **Known limitation:** a background job whose owning interactive session
  isn't currently live (crashed, respawned under a new id, or launched
  without ever having a parked pane) has no tmux pane to point you at, and
  is deliberately not counted -- there's nothing to navigate to. This means
  the total can undercount genuinely-running background work in that
  specific case.
- Liveness is checked with `kill -0 <pid>` plus a `ps -o comm=` match on
  `claude`, guarding against a stale file whose PID has been reused by an
  unrelated process.
- State mapping: `waiting` -> `waiting`; `busy` -> `running`; `shell` /
  `idle` -> `done`. `shell` is a substate of idle (idle, with a live
  background shell attached), not of busy. There is no "seen" tracking --
  an agent idle for days still counts as done.
