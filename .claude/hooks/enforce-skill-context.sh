#!/bin/bash
# enforce-skill-context.sh — @gumgum/resonance hooks v0.15.1
# Delegates to package implementation. Replace this file to override.

HOOK_NAME="enforce-skill-context.sh"

# Try to find the package hook implementation
for BASE in "${CLAUDE_PROJECT_DIR:-.}" "${CLAUDE_PROJECT_DIR:-.}/.."; do
  PKG_HOOK="$BASE/node_modules/@gumgum/resonance/claude/hooks/$HOOK_NAME"
  if [ -f "$PKG_HOOK" ]; then
    exec bash "$PKG_HOOK"
  fi
done

# ── Inline fallback (package not found in node_modules) ──
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
if ! echo "$FILE_PATH" | grep -qiE '\.(tsx|jsx)$'; then exit 0; fi
if ! echo "$FILE_PATH" | grep -qE 'src/'; then exit 0; fi
if echo "$FILE_PATH" | grep -qE 'packages/resonance|node_modules'; then exit 0; fi
NEW_STRING=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')
if [ -z "$NEW_STRING" ]; then exit 0; fi
if ! echo "$NEW_STRING" | grep -qE "from ['\"]@gumgum/resonance|var\(--gg-"; then exit 0; fi
FILE_STEM=$(basename "$FILE_PATH" | sed -E 's/\.(tsx|jsx)$//' | tr -cd 'a-zA-Z0-9_-')
PROJECT_HASH=$(basename "${CLAUDE_PROJECT_DIR:-$(pwd)}")
MARKER="/tmp/.gg-skills-loaded-${PROJECT_HASH}-${FILE_STEM}"
if [ -f "$MARKER" ]; then
  STALE=$(find "$MARKER" -mmin +10 2>/dev/null)
  if [ -z "$STALE" ]; then exit 0; fi
  rm -f "$MARKER"
fi
jq -n --arg m "$MARKER" '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: ("BLOCKED: Load DS skills first. After reading skills, run: touch " + $m) } }'
exit 0
