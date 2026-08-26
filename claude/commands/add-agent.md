---
description: Install a subagent from VoltAgent/awesome-claude-code-subagents, patched to this machine's conventions.
argument-hint: <agent-name> [model] [effort]
---

Install a subagent from `VoltAgent/awesome-claude-code-subagents` into the tracked agents directory, applying the standard patch.

Arguments: `$ARGUMENTS` — first token is the agent name (e.g. `terraform-engineer`), optional second is the model (default `sonnet`), optional third is the effort (default `medium`).

If no agent name was given, list the categories from the repo's README and ask which agent they want. Do not guess.

## Before installing - push back once

Installing costs roughly 80 tokens of main-context system prompt on **every** session, forever. The standing rule is: inline the persona for a one-off, install only when it recurs.

So unless the user has already said this is recurring, say in one line what the inline alternative would be — for example, spawning `analyst` or `builder` with "you are a Terraform specialist; focus on state, module boundaries, and drift" in the prompt — and ask whether they still want it installed. Accept their answer either way and move on; do not argue twice.

## Procedure

1. **Locate the file.** The category directory varies, so resolve the path rather than guessing it:

   ```
   gh api "repos/VoltAgent/awesome-claude-code-subagents/git/trees/main?recursive=1" \
     --jq '.tree[].path | select(endswith("/<name>.md"))'
   ```

   If `gh` is unavailable, fall back to the same URL via `curl` (unauthenticated, and rate-limited — say so if it fails).

   No match: report that the agent does not exist in the repo, suggest the closest names from the tree, and stop.

2. **Check it is not already installed.** If `~/Documents/Repo/dot-files/claude/agents/<name>.md` exists, say so and stop. Do not silently overwrite.

3. **Fetch** the raw file from `https://raw.githubusercontent.com/VoltAgent/awesome-claude-code-subagents/main/<path>`.

4. **Patch it**, exactly as the existing imported agents were patched:
   - Cut everything from the line `## Communication Protocol` to end of file. That block addresses a `context-manager` agent over a JSON protocol that never existed — the repo maintainer confirmed in issue #300 that it was "decorative and misleading" — and the tail restates content already above it. If the marker is absent, keep the body whole and note that in the summary.
   - Rewrite the frontmatter to exactly: `name`, `description`, `model`, `effort`, `tools`.
   - `description` becomes **one sentence** stating when to delegate to it. That string is what costs main-context tokens every session, so it must be short and specific. Do not keep the upstream description.
   - `tools`: keep upstream's list unless it grants more than the agent needs. A review-only or analysis-only agent should lose `Write` and `Edit`.

5. **Write** to `~/Documents/Repo/dot-files/claude/agents/<name>.md` — the tracked dotfiles path, not `~/.claude/agents/` (which is a symlink to it).

6. **Verify** the frontmatter parses and `name` matches the filename. Valid `model`: `sonnet`, `opus`, `haiku`, `fable`, `inherit`, or a full model ID. Valid `effort`: `low`, `medium`, `high`, `xhigh`, `max`.

7. **Report**: the original and patched byte sizes, the resolved model and effort, and the one-line description you wrote. Then tell the user to run `/reload-plugins` to activate it in this session — no restart needed.

Finally, if the roster is now above roughly 25 agents, mention the standing cost and suggest reviewing which are actually getting selected. Do not remove anything on your own.
