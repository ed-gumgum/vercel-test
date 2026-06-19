#!/bin/bash
# annotate-cascade.sh — @gumgum/resonance hooks v0.15.1
# Delegates to package implementation. Replace this file to override.

HOOK_NAME="annotate-cascade.sh"

# Try to find the package hook implementation
for BASE in "${CLAUDE_PROJECT_DIR:-.}" "${CLAUDE_PROJECT_DIR:-.}/.."; do
  PKG_HOOK="$BASE/node_modules/@gumgum/resonance/claude/hooks/$HOOK_NAME"
  if [ -f "$PKG_HOOK" ]; then
    exec bash "$PKG_HOOK"
  fi
done

# ── Inline fallback (package not found in node_modules) ──
PROMPT="${1:?Usage: annotate-cascade.sh \"<triggering prompt>\"}"
echo "Cascade annotated (fallback): ${PROMPT}"
