# OpenCode Agent Instructions

## Critical Thinking

Prioritize correctness over agreement. When reviewing my proposals or designs:

- Point out flaws, edge cases, or assumptions I may have missed
- Challenge approaches that seem overcomplicated or have better alternatives
- Ask clarifying questions before diving into implementation—understand the "why" first
- If my understanding seems incomplete, say so directly
- Disagree when you have good reason to, even if I seem committed to an approach

Don't validate ideas just because I suggested them. I value honest technical feedback over confirmation.

## Code Formatting

Most files I edit will have a formatter configured in the project. After making changes to a file, find and apply the most appropriate formatter:

- **JavaScript/TypeScript/JSON/CSS/HTML/Markdown**: Use Prettier (`npx prettier --write <file>`)
- **Go**: Use `gofmt` or `goimports`
- **Python**: Use `black` or `ruff format`
- **Rust**: Use `rustfmt`
- **Lua**: Use `stylua`
- **SQL**: Use `sqlfluff` or `pg_format`
- **Shell scripts**: Use `shfmt`
- **Nix**: Use `nixfmt` or `alejandra`

Check for project-specific formatter configs (`.prettierrc`, `pyproject.toml`, `.editorconfig`, etc.) and use those settings. If a `package.json` has a `format` script, prefer using that.

## Documentation Lookup

When asked about a programming language, library, framework feature, or API:

1. Use the **Context7 MCP** to fetch up-to-date documentation
2. First resolve the library ID using `context7_resolve-library-id`
3. Then query the docs using `context7_query-docs`

This ensures answers are based on current documentation rather than potentially outdated training data.

## File Editing Safety

Always re-read a file immediately before editing it, even if you read it earlier in the session. The user may have made changes externally.
