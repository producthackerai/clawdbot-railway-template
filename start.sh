#!/bin/bash
# Boot script for TaskCrush OpenClaw deployment.
# Syncs custom skills and workspace files from the Docker image (/app/)
# into the persistent Railway volume (/data/workspace/), then starts
# the OpenClaw wrapper server.

set -e

WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-/data/workspace}"
SKILLS_DIR="$WORKSPACE_DIR/skills"

echo "[start.sh] TaskCrush OpenClaw boot"
echo "[start.sh] WORKSPACE_DIR=$WORKSPACE_DIR"

# Ensure directories exist
mkdir -p "$WORKSPACE_DIR" "$SKILLS_DIR"

# Sync custom skills (always overwrite to pick up image updates)
if [ -d "/app/skills" ]; then
  echo "[start.sh] Syncing HiveForge skills..."
  cp -r /app/skills/* "$SKILLS_DIR/" 2>/dev/null || true
  SKILL_COUNT=$(find "$SKILLS_DIR" -name "SKILL.md" 2>/dev/null | wc -l)
  echo "[start.sh] $SKILL_COUNT skill(s) installed"
fi

# Sync workspace personality files
# DECISIONS.md and MEMORY.md are no-clobber: seeded on first boot, then preserved
# across deploys so runtime edits (holds, memory) survive restarts.
NO_CLOBBER_FILES="DECISIONS.md MEMORY.md"

if [ -d "/app/workspace" ]; then
  echo "[start.sh] Syncing workspace personality files..."
  for f in /app/workspace/*.md; do
    [ -f "$f" ] || continue
    BASENAME=$(basename "$f")
    TARGET="$WORKSPACE_DIR/$BASENAME"
    if echo "$NO_CLOBBER_FILES" | grep -qw "$BASENAME" && [ -f "$TARGET" ]; then
      echo "[start.sh]   $BASENAME (preserved — no-clobber)"
    else
      cp "$f" "$TARGET" && echo "[start.sh]   $BASENAME"
    fi
  done
fi

# Persona-specific overrides (after main sync)
PERSONA="${OPENCLAW_PERSONA:-producthacker}"
PERSONA_DIR="/app/bots/$PERSONA/workspace"
if [ -d "$PERSONA_DIR" ]; then
  echo "[start.sh] Applying persona: $PERSONA"

  # Override workspace .md files (SOUL.md, AGENTS.md, etc.)
  for f in "$PERSONA_DIR"/*.md; do
    [ -f "$f" ] || continue
    BASENAME=$(basename "$f")
    TARGET="$WORKSPACE_DIR/$BASENAME"
    cp "$f" "$TARGET" && echo "[start.sh]   $BASENAME (persona override)"
  done

  # Sync persona-specific skills (merge into shared skills dir)
  PERSONA_SKILLS="/app/bots/$PERSONA/skills"
  if [ -d "$PERSONA_SKILLS" ]; then
    echo "[start.sh] Syncing persona skills..."
    cp -r "$PERSONA_SKILLS/"* "$SKILLS_DIR/" 2>/dev/null || true
    echo "[start.sh]   Persona skills merged into $SKILLS_DIR"
  fi
fi

# Harden credentials dir permissions (fix OpenClaw security audit warning)
STATE_DIR="${OPENCLAW_STATE_DIR:-/data/.openclaw}"
if [ -d "$STATE_DIR/credentials" ]; then
  chmod 700 "$STATE_DIR/credentials"
  echo "[start.sh] Credentials dir permissions hardened (700)"
fi

# Non-blocking HiveForge connectivity check
if [ -n "$HIVEFORGE_API_URL" ]; then
  if curl -sf --max-time 3 "$HIVEFORGE_API_URL/health" > /dev/null 2>&1; then
    echo "[start.sh] HiveForge MCP reachable at $HIVEFORGE_API_URL"
  else
    echo "[start.sh] WARNING: HiveForge MCP not reachable at $HIVEFORGE_API_URL (skills will fail)"
  fi
fi

echo "[start.sh] Starting OpenClaw wrapper..."
exec node /app/src/server.js
