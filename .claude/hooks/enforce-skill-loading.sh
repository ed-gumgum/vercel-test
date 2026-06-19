#!/bin/bash
# enforce-skill-loading.sh — @gumgum/resonance hooks v0.15.1
# Delegates to package implementation. Replace this file to override.

HOOK_NAME="enforce-skill-loading.sh"

# Try to find the package hook implementation
for BASE in "${CLAUDE_PROJECT_DIR:-.}" "${CLAUDE_PROJECT_DIR:-.}/.."; do
  PKG_HOOK="$BASE/node_modules/@gumgum/resonance/claude/hooks/$HOOK_NAME"
  if [ -f "$PKG_HOOK" ]; then
    exec bash "$PKG_HOOK"
  fi
done

# ── Inline fallback (package not found in node_modules) ──
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.tool_input.prompt // empty')
if [ -z "$PROMPT" ]; then exit 0; fi
if echo "$PROMPT" | grep -qE 'skills/resonance\.md|@gumgum/resonance/skills/'; then exit 0; fi
jq -n '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: "BLOCKED: This project uses @gumgum/resonance. Subagents must load the DS skill system. Add: \"First read node_modules/@gumgum/resonance/skills/resonance.md and follow its routing protocol.\"" } }'
exit 0
