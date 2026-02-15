---
name: hiveforge-goals
description: List and create TaskCrush goals, track progress, and link tasks to goals
---

# HiveForge Goals

Manage TaskCrush goals through the HiveForge MCP gateway.

## Configuration

Requires environment variables:
- `HIVEFORGE_API_URL` — HiveForge MCP base URL
- `HIVEFORGE_SERVICE_KEY` — Service key for authentication

## Available Actions

### List Goals

Get goals from a workspace.

```bash
curl -s -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/goals?workspace=personal" | jq
```

Optional query parameters:
- `workspace` — `personal` or `work` (default: personal)
- `status` — `active`, `completed`, or `archived`

### Create Goal

Create a new goal. Always confirm with the user before creating.

```bash
curl -s -X POST -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/goals" \
  -d '{
    "title": "Goal title here",
    "description": "What success looks like",
    "workspace": "personal"
  }' | jq
```

Fields:
- `title` (required) — Goal title
- `description` — Optional description
- `workspace` — `personal` or `work` (default: personal)
- `parentGoalId` — Optional parent goal for sub-goals

## Guidelines

- Goals are higher-level objectives that tasks contribute to
- When reporting goal progress, mention related tasks and their status
- Never create goals in the `app` workspace
- Confirm before creating new goals
