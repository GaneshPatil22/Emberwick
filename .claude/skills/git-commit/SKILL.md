---
name: git-commit
description: Stage all changes and commit them with a generated commit message — a concise title plus a 5–6 line body. Use when the user wants to quickly commit the current work.
---

Stage every change and create a single commit with a well-written, multi-line message.

## Steps

1. **Understand the changes.** Run `git status --short`, `git diff --stat`, and skim `git diff` / `git diff --staged` so the message describes what actually changed.
2. **If there is nothing to commit**, say so and stop.
3. **Stage everything:** `git add -A` (includes new, modified, and deleted files).
4. **Compose the message:**
   - **Title:** one concise, imperative line (~50–65 chars, no trailing period), specific to the change — not generic like "update files".
   - Blank line.
   - **Body:** 5–6 lines summarizing *what* changed and *why*, wrapped ~72 cols (short bullets or prose).
   - Blank line, then the required trailer exactly:
     `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`
5. **Commit** preserving the multi-line body — write the message to a temp file and use `git commit -F`, e.g.:
   ```
   git commit -F - <<'EOF'
   <title>

   <body line 1>
   <body line 2>
   ...

   Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
   EOF
   ```
6. **Confirm:** show `git log -1 --stat` (or `git show --stat HEAD`).

## Rules

- Commit only — never `push` unless the user explicitly asks.
- Do not create a branch or amend unless asked; commit on the current branch.
- Keep the title tied to the real change; use the body for the details.
