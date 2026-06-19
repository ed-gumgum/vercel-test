#!/bin/bash
# post-write-dom-check.sh — @gumgum/resonance hooks v0.15.1
# Delegates to package implementation. Replace this file to override.

HOOK_NAME="post-write-dom-check.sh"

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
jq -n --arg f "$FILE_PATH" '{ hookSpecificOutput: { hookEventName: "PostToolUse", notification: ("UI file written: " + $f + ". Remember to visually verify.") } }'
exit 0
