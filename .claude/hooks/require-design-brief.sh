#!/bin/bash
# require-design-brief.sh — @gumgum/resonance hooks v0.15.1
# Delegates to package implementation. Replace this file to override.

HOOK_NAME="require-design-brief.sh"

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
if ! echo "$FILE_PATH" | grep -qE 'src/(components|pages|views|features)/'; then exit 0; fi
if echo "$FILE_PATH" | grep -qE 'packages/resonance|node_modules|pages/components/'; then exit 0; fi
COMP=$(basename "$FILE_PATH" | sed -E 's/\.(tsx|jsx)$//')
if [ "$COMP" = "index" ]; then COMP=$(basename "$(dirname "$FILE_PATH")"); fi
PROJECT_HASH=$(basename "${CLAUDE_PROJECT_DIR:-$(pwd)}")
BRIEF="/tmp/.gg-design-brief-${PROJECT_HASH}-${COMP}"
if [ ! -f "$BRIEF" ]; then
  jq -n --arg b "$BRIEF" --arg c "$COMP" '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: ("BLOCKED: No design brief for \"" + $c + "\". Write a plan to: " + $b + " with 3+ DS token refs (gap=, size=, <Flex, etc.)") } }'
  exit 0
fi
TOKEN_COUNT=0
for p in gap= size= variant= intent= "<Flex" "<Grid" "<Card" "<Heading" "<Text" "<Button" "--gg-"; do
  if grep -qF -- "$p" "$BRIEF"; then TOKEN_COUNT=$((TOKEN_COUNT + 1)); fi
done
if [ "$TOKEN_COUNT" -lt 3 ]; then
  jq -n --arg b "$BRIEF" '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: ("BLOCKED: Brief at " + $b + " needs 3+ DS token references.") } }'
  exit 0
fi
exit 0
