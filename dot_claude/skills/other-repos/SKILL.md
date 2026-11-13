---
name: other-repos
description:
  Work in a repository other than the current one. Use when I ask to read,
  change, or check something in another repo (e.g. "make a change in platform-shared",
  "check how infra does X"). All work repos live under ~/git/work/.
---

# Working in other repos

All work repos are checked out under `~/git/work/<repo-name>`.

## Before touching another repo

1. Read its `CLAUDE.md` (and `.claude/rules/` if present). These are NOT loaded
   automatically for directories outside the launch repo, so follow them manually.
2. Check `git status` there. Don't work on top of someone's uncommitted changes.
3. For anything beyond a small edit, create a worktree with treehouse rather than
   editing the main checkout (see the treehouse skill).

## When done

Summarise what changed in each repo separately, with paths, since commits and PRs
are per-repo.
