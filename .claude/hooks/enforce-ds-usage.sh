#!/bin/bash
# enforce-ds-usage.sh — @gumgum/resonance hooks v0.15.1
# Delegates to package implementation. Replace this file to override.

HOOK_NAME="enforce-ds-usage.sh"

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
if ! echo "$FILE_PATH" | grep -qE 'src/'; then exit 0; fi
if echo "$FILE_PATH" | grep -qE 'node_modules|packages/resonance'; then exit 0; fi
if ! echo "$FILE_PATH" | grep -qiE '\.(tsx|jsx)$'; then exit 0; fi
NEW_STRING=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')
if [ -z "$NEW_STRING" ]; then exit 0; fi
if echo "$NEW_STRING" | grep -qE 'ds-exempt-file:'; then exit 0; fi
BLOCKS=""
if echo "$NEW_STRING" | grep -qE '<h[1-6][> /]'; then BLOCKS="${BLOCKS}\n- <h1>-<h6> → <Heading as={N}>"; fi
if echo "$NEW_STRING" | grep -qE '<button[> /]'; then BLOCKS="${BLOCKS}\n- <button> → <Button>"; fi
if echo "$NEW_STRING" | grep -qE '<input[> /]'; then BLOCKS="${BLOCKS}\n- <input> → <Input>"; fi
if echo "$NEW_STRING" | grep -qE '<Icon[[:space:]]+name='; then BLOCKS="${BLOCKS}\n- <Icon name=...> → <Icon icon={Ref}>"; fi
if [ -z "$BLOCKS" ]; then exit 0; fi
jq -n --arg b "$BLOCKS" '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: ("BLOCKED: DS violations:" + $b + "\n\nUse @gumgum/resonance components. Add // ds-exempt: <reason> to bypass.") } }'
exit 0
