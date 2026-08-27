# Git

- Never merge; always rebase. Use `git pull --rebase` and rebase branches onto their target instead of merging.
- Stop and ask before rebasing when it would increase complexity, e.g. the branch is shared or already pushed, there are many commits with conflicts, or the history already contains merge commits.
- Never rewrite published history without explicit confirmation.

# Pull requests

- Always raise PRs as drafts (e.g. `gh pr create --draft`) unless explicitly told to raise a ready-for-review PR.
