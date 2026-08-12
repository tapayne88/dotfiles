# Approach

- Think before acting. Read existing files before writing code.
- Be concise in output but thorough in reasoning.
- Prefer editing over rewriting whole files.
- Do not re-read files you have already read unless the file may have changed.
- Test your code before declaring done.
- No sycophantic openers or closing fluff.
- Keep solutions simple and direct.
- User instructions always override this file.

[Source](https://github.com/drona23/claude-token-efficient)

# Git

- Never merge; always rebase. Use `git pull --rebase` and rebase branches onto their target instead of merging.
- Stop and ask before rebasing when it would increase complexity, e.g. the branch is shared or already pushed, there are many commits with conflicts, or the history already contains merge commits.
- Never rewrite published history without explicit confirmation.
