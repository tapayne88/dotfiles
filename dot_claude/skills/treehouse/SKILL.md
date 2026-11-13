---
name: treehouse
description:
  Provision, list, and clean up git worktrees using treehouse. Use whenever I ask
  for a new worktree, a parallel branch to work on, or a clean checkout of another repo,
  instead of running `git worktree` directly.
---

# Treehouse worktrees

Always use treehouse rather than `git worktree add`. Treehouse keeps a pool of reusable
worktrees per repo; run its commands from inside the repo (or pass a path).

## Create

`treehouse get --lease [-b <branch>] [--base <branch>]`

- Always pass `--lease`. Without it `get` opens an interactive subshell and will hang.
- Prints only the worktree's absolute path on stdout (banners go to stderr). Slots live
  at `{pool}/{slot}/{repo}`; use the printed path, don't guess it.
- Worktrees start in detached HEAD cut from the inferred default branch. Pass `-b` with
  a descriptive branch name when making changes; `--base` to cut from another branch.

## List

`treehouse status` (or `--json`) shows each slot's name, path, status and lease.

## Return

`treehouse return <path>` releases the lease and hands the worktree back to the pool.
Only do this when I ask, or for a worktree you created that has no unpushed work.
Never run `treehouse destroy` or `prune` without asking me first.

## After creating

- Work in the printed path. Ignored files listed in `.worktreeinclude` are already
  seeded; for anything else (deps, codegen) follow that repo's CLAUDE.md.
- Tell me the path so I can open a pane there. Don't run `treehouse-tmux` yourself:
  it opens interactive sessions.
