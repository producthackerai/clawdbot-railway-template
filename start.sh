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

# Sync workspace personality files (always overwrite)
if [ -d "/app/workspace" ]; then
  echo "[start.sh] Syncing workspace personality files..."
  for f in /app/workspace/*.md; do
    [ -f "$f" ] && cp "$f" "$WORKSPACE_DIR/" && echo "[start.sh]   $(basename "$f")"
  done
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
